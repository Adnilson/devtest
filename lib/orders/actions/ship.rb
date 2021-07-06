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
        yield validate_complete_order(order)
        user = yield fetch_user(order)
        address = yield fetch_address(user)

        yield ship(order, address)

        Success(Orders::Api::DTO::Order.new(order.attributes.symbolize_keys))
      end

      private

      attr_reader :order_id

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

      def fetch_user(order)
        user = Users::Models::User.find_by(id: order.buyer_id)

        user ? Success(user) : Failure({ code: :user_not_found })
      end

      def fetch_address(user)
        address = user.address

        address ? Success(format_address(address)) : Failure({ code: :address_not_found })
      end

      def format_address(address)
        [address.street, address.zip_code, address.city].join(', ')
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
