# frozen_string_literal: true

require "dry/monads/do"

module Users
  module Actions
    class CreateAddress
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
        user = yield fetch_user
        yield check_if_user_has_already_an_address(user)
        address = yield create_address

        Success(Users::Api::DTO::Address.new(address.attributes.symbolize_keys))
      end

      private

      attr_reader :params

      def fetch_user
        user = Users::Models::User.find_by(id: params[:user_id])

        user ? Success(user) : Failure({ code: :user_not_found })
      end

      def check_if_user_has_already_an_address(user)
        user.address.nil? ? Success() : Failure({ code: :address_already_created })
      end

      def create_address
        address = Users::Models::Address.create(params.to_h)

        if address.errors.empty?
          Success(address)
        else
          Failure({ code: address_not_created, details: address.errors.to_hash })
        end
      end
    end
  end
end