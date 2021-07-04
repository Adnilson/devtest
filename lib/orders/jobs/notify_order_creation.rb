# frozen_string_literal: true

module Orders
  module Jobs
    class NotifyOrderCreation
      include Sidekiq::Worker

      def perform(order_id)
        ::Orders::Api::Order.notify_order_creation(order_id)
      end
    end
  end
end
