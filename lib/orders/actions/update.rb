# frozen_string_literal: true

require "dry/monads/do"

module Orders
  module Actions
    class Update
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(order_id:, shipping_method: nil, payment_method: nil)
        @order_id = order_id
        @shipping_method = shipping_method
        @payment_method = payment_method
      end

      def call
        order = yield fetch_order
        yield validate_order_status(order)
        self.shipping_costs = yield calculate_shipping_costs(order) if shipping_method_present?
        yield update(order)

        Success(Orders::Api::DTO::Order.new(order.attributes.symbolize_keys))
      end

      private

      attr_reader :order_id, :shipping_method, :payment_method
      attr_accessor :shipping_costs

      def fetch_order
        order = Orders::Models::Order.find_by(id: order_id)

        order ? Success(order) : Failure({ code: :order_not_found })
      end

      def validate_order_status(order)
        if order.status.eql?("shipped")
          Failure({ code: :order_not_updated, details: { base: ["can't update shipped order"] } })
        else
          Success()
        end
      end

      def shipping_method_present?
        !(shipping_method.nil? || shipping_method.empty?)
      end

      def calculate_shipping_costs(order)
        Orders::Actions::CalculateShippingCosts.call(auction_id: order.auction_id, shipping_method: shipping_method)
      end

      def update(order)
        order.update(update_params)

        if order.errors.empty?
          Success()
        else
          Failure({ code: :order_not_updated, details: order.errors.to_hash })
        end
      end

      def update_params
        {
          shipping_method: shipping_method,
          payment_method: payment_method,
          shipping_costs: shipping_costs
        }.compact
      end
    end
  end
end
