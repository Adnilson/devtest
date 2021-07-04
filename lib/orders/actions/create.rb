# frozen_string_literal: true

require "dry/monads/do"

module Orders
  module Actions
    class Create
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(params:)
        @params = params
      end

      def call
        order = yield create_order

        notify_order_creation(order)

        Success(Orders::Api::DTO::Order.new(order.attributes.symbolize_keys))
      end

      private

      attr_reader :params

      def create_order
        order = Orders::Models::Order.create(order_params)

        if order.errors.empty?
          Success(order)
        else
          Failure({ code: :order_not_created, details: order.errors.to_hash })
        end
      end

      def order_params
        params.to_h.merge(
          status: "draft",
          reference_number: generate_reference_number
        )
      end

      def generate_reference_number
        "#{Time.now.strftime("%y%m%d")}_#{SecureRandom.hex[..10]}"
      end

      def notify_order_creation(order)
        Orders::Jobs::NotifyOrderCreation.perform_async(order.id)
      end
    end
  end
end
