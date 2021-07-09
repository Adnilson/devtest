# frozen_string_literal: true

module Users
  module Api
    module DTO
      class AddressParams < Dry::Struct
        attribute :street, Types::String
        attribute :zip_code, Types::String
        attribute :city, Types::String
        attribute :user_id, Types::UUID
      end
    end
  end
end
