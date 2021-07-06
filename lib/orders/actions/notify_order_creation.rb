# frozen_string_literal: true

require "dry/monads/do"

module Orders
  module Actions
    EMAIL_SUBJECT = "Con-Gra-Tu-Laaaa-tions!"

    class NotifyOrderCreation
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)
      include OrderDependencies[:find_user, :send_email]

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(order_id:, find_user:, send_email:)
        @order_id = order_id
        @find_user = find_user
        @send_email = send_email
      end

      def call
        order = yield fetch_order
        user = yield find_user.call(order.buyer_id)

        send_email.call(params(order, user))

        Success("Notification sent!")
      end

      private

      attr_reader :order_id

      def fetch_order
        order = Orders::Models::Order.find_by(id: order_id)

        order ? Success(order) : Failure({ code: :order_not_found })
      end

      def params(order, user)
        [
          user.email,
          EMAIL_SUBJECT,
          {
            reference_number: order.reference_number,
            total_payment: order.total_payment,
            auction_id: order.auction_id
          }
        ]
      end
    end
  end
end
