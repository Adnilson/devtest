# frozen_string_literal: true

require "dry/monads/do"

module Orders
  module Actions
    EMAIL_SUBJECT = "Con-Gra-Tu-Laaaa-tions!"

    class NotifyOrderCreation
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
        user = yield fetch_user(order)
        
        send_email(order, user)
        
        Success("E-mail sent")
      end

      private

      attr_reader :order_id

      def fetch_order
        order = Orders::Models::Order.find_by(id: order_id)

        order ? Success(order) : Failure({ code: :order_not_found })
      end

      def fetch_user(order)
        user = Users::Models::User.find_by(id: order.buyer_id)

        user ? Success(user) : Failure({ code: :user_not_found })
      end

      def send_email(order, user)
        variables = {
          reference_number: order.reference_number,
          total_payment: order.total_payment,
          auction_id: order.auction_id
        }

        ::EmailDelivery::Api::Email.deliver(
          user.email,
          EMAIL_SUBJECT,
          variables
        )
      end
    end
  end
end