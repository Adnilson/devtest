# frozen_string_literal: true

module Auctions
  module Jobs
    class NotifyLosingBidders
      include Sidekiq::Worker

      def perform(auction_id)
        ::Auctions::Api::Auction.notify_losing_bidders(auction_id)
      end
    end
  end
end
