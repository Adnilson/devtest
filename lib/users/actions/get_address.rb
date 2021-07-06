# frozen_string_literal: true

require "dry/monads/do"

module Users
  module Actions
    class GetAddress
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(user_id:)
        @user_id = user_id
      end

      def call
        user = yield fetch_user
        address_string = yield fetch_address(user)

        Success(address_string)
      end

      private

      attr_reader :user_id

      def fetch_user
        user = Users::Models::User.find_by(id: user_id)

        user ? Success(user) : Failure({ code: :user_not_found })
      end

      def fetch_address(user)
        address = user.address

        address ? Success(create_address_string(address)) : Failure({ code: :address_not_found })
      end

      def create_address_string(address)
        [address.street, address.zip_code, address.city].join(', ')
      end
    end
  end
end
