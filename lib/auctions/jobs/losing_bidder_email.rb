# frozen_string_literal: true

module Auctions
  module Jobs
    class LosingBidderEmail
      include Sidekiq::Worker
      include AuctionDependencies[:send_email]

      def perform(email, subject, variables)
        send_email.call([email, subject, variables])
      end
    end
  end
end
