# frozen_string_literal: true

module Orders
  module Api
    module DTO
      class Order < Dry::Struct
        Status = Types::String.enum("draft", "shipped")

        attribute :id, Types::UUID
        attribute :auction_id, Types::UUID
        attribute :buyer_id, Types::UUID
        attribute :reference_number, Types::String
        attribute :total_payment, Types::Decimal | Types::Float
        attribute :shipping_method, Types::String.optional.default(nil)
        attribute :payment_method, Types::String.optional.default(nil)
        attribute :status, Status
      end
    end
  end
end
