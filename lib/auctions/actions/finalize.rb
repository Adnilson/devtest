# frozen_string_literal: true

require "dry/monads/do"

module Auctions
  module Actions
    class Finalize
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)
      include AuctionDependencies[:create_order]

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(auction_id:, create_order:)
        @auction_id = auction_id
        @create_order = create_order
      end

      def call
        auction = yield fetch_auction
        closed_auction = yield close(auction)
        yield create_order.call(order_params(closed_auction))

        Success(Auctions::Api::DTO::Auction.new(closed_auction.attributes.symbolize_keys))
      end

      private

      attr_reader :auction_id, :create_order

      def fetch_auction
        auction = Auctions::Models::Auction.find_by(id: auction_id)

        auction ? Success(auction) : Failure({ code: :auction_not_found })
      end

      def close(auction)
        if Time.now >= auction.finishes_at
          auction.close
          auction.save

          auction.errors.empty? ? Success(auction) : Failure(failure_details(auction))
        else
          Failure({ code: :auction_not_finished_yet })
        end
      end

      def failure_details(auction)
        { code: :auction_not_finalized, details: auction.errors.to_hash }
      end

      def order_params(auction)
        {
          auction_id: auction.id,
          total_payment: auction.bids.find_by(bidder_id: auction.winner_id).amount
        }
      end
    end
  end
end
