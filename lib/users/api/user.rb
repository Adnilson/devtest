# frozen_string_literal: true

module Users
  module Api
    class User
      class << self
        # @param id [Integer] Id of the user to get
        # @return [Dry::Monads::Result<Users::Api::DTO::User, Failure>] User as DTO in case of success,
        # or a Failure object
        def get_by_id(id)
          ::Users::Actions::GetById.call(user_id: id)
        end

        # @param address_params [Users::API::DTO::AddressParams] Params for a new address
        # @return [Dry::Monads::Result<Users::API::DTO::Address, Failure>] Address as DTO in case of success,
        # or a Failure object
        def create_address(address_params)
          ::Users::Actions::CreateAddress.call(params: address_params)
        end

        # @param id [Integer] Id of the user to get its address
        # @return [Dry::Monads::Result<String, Failure>] Address string in case of success,
        # or a Failure object
        def get_address(id)
          ::Users::Actions::GetAddress.call(user_id: id)
        end
      end
    end
  end
end
