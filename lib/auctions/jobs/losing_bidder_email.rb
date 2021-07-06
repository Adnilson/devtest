# frozen_string_literal: true

module Auctions
  module Jobs
    class LosingBidderEmail
      include Sidekiq::Worker

      def perform(email, subject, variables)
        ::EmailDelivery::Api::Email.deliver(email, subject, variables)
      end
    end
  end
end
