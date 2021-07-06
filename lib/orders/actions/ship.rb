# frozen_string_literal: true

require "dry/monads/do"

module Orders
  module Actions
    class Ship
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)
      include OrderDependencies[:get_address]

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(order_id:, get_address:)
        @order_id = order_id
        @get_address = get_address
      end

      def call
        order = yield fetch_order
        yield validate_complete_order(order)
        address = yield get_address.call(order.buyer_id)
        yield ship(order, address)

        Success(Orders::Api::DTO::Order.new(order.attributes.symbolize_keys))
      end

      private

      attr_reader :order_id, :get_address

      def fetch_order
        order = Orders::Models::Order.find_by(id: order_id)

        order ? Success(order) : Failure({ code: :order_not_found })
      end

      def validate_complete_order(order)
        if order.payment_method && order.shipping_method
          Success()
        else
          details = {
            payment_method: order.payment_method ? nil : ["is missing"],
            shipping_method: order.shipping_method ? nil : ["is missing"],
          }.compact

          Failure({ code: :order_not_shipped, details: details })
        end
      end

      def ship(order, address)
        order.shipping_address = address
        order.status = "shipped"
        order.save

        if order.errors.empty?
          Success()
        else
          Failure({ code: :order_not_shipped, details: order.errors.to_hash })
        end
      end
    end
  end
end
