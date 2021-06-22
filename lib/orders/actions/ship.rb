# frozen_string_literal: true

require "dry/monads/do"

module Orders
  module Actions
    class Ship
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(order_id:)
        @order_id = order_id
      end

      def call
        order = yield fetch_order
        yield ship(order)

        Success(Orders::Api::Dto::Order.from_active_record(order))
      end

      private

      attr_reader :order_id

      def fetch_order
        order = Orders::Models::Order.find_by(id: order_id)

        order ? Success(order) : Failure({ code: :order_not_found })
      end

      def ship(order)
        if order.payment_method && order.shipping_method
          order.ship
          order.save

          order.errors.empty? ? Success(order) : Failure({ code: :order_not_shipped, details: order.errors.to_hash })
        else
          details = {
            payment_method: order.payment_method ? nil : ["is missing"],
            shipping_method: order.shipping_method ? nil : ["is missing"],
          }.compact

          Failure({ code: :order_not_shipped, details: details })
        end
      end
    end
  end
end