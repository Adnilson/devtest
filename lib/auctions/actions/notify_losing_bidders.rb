# frozen_string_literal: true

require "dry/monads/do"

module Auctions
  module Actions
    EMAIL_SUBJECT = "Sorry seems to be the hardest word..."

    class NotifyLosingBidders
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)
      include AuctionDependencies[:fetch_emails]

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(auction_id:, fetch_emails:)
        @auction_id = auction_id
        @fetch_emails = fetch_emails
      end

      def call
        auction = yield fetch_auction
        bidders_ids = yield fetch_bidder_ids(auction)
        emails = yield fetch_emails.call(bidders_ids)
        
        send_emails(auction, emails)
        
        Success("Notifications sent!")
      end

      private

      attr_reader :auction_id

      def fetch_auction
        auction = Auctions::Models::Auction.find_by(id: auction_id)

        auction ? Success(auction) : Failure({ code: :auction_not_found })
      end

      def fetch_bidder_ids(auction)
        ids = auction.bids.where(auction_id: auction.id).pluck(:bidder_id).uniq
  
        if ids.size > 1
          Success(remove_winner_id(ids, auction))
        else
          Failure({ code: :no_losing_bidders })
        end
      end

      def remove_winner_id(ids, auction)
        ids - [auction.winner_id]
      end

      def send_emails(auction, emails)
        variables = { highest_bid: highest_bid(auction), auction_id: auction.id }

        emails.each do |email|
          Auctions::Jobs::LosingBidderEmail.perform_async(
            email,
            EMAIL_SUBJECT,
            variables
          )
        end
      end

      def highest_bid(auction)
        auction.bids.order("amount desc").first.amount
      end
    end
  end
end
