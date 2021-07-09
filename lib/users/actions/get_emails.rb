# frozen_string_literal: true

require "dry/monads/do"

module Users
  module Actions
    class GetEmails
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(users_ids:)
        @users_ids = users_ids
      end

      def call
        users = Users::Models::User.where(id: users_ids)

        users.empty? ? Failure({ code: :users_not_found }) : Success(users.pluck(:email))
      end

      private

      attr_reader :users_ids
    end
  end
end
