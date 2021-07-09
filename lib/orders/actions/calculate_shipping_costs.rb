# frozen_string_literal: true

require "dry/monads/do"

module Orders
  module Actions
    class CalculateShippingCosts
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)
      include OrderDependencies[:fetch_joke]

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(auction_id:, shipping_method:, fetch_joke:)
        @auction_id = auction_id
        @shipping_method = shipping_method
        @fetch_joke = fetch_joke
      end

      def call
        auction = yield fetch_auction
        shipping_costs = yield calculate_shipping_costs(auction)

        Success(shipping_costs)
      end

      private

      attr_reader :auction_id, :shipping_method, :fetch_joke

      def fetch_auction
        auction = Auctions::Models::Auction.find_by(id: auction_id)

        auction ? Success(auction) : Failure({ code: :auction_not_found })
      end

      def calculate_shipping_costs(auction)
        Success(calculate[shipping_method].call(auction))
      end

      def calculate
        {
          "air" => method(:calculate_air_shipping),
          "ground" => method(:calculate_ground_shipping)
        }
      end

      def calculate_air_shipping(auction)
        auction.package_weight.ceil * 2
      end

      def calculate_ground_shipping(auction)
        package_dimension = [
          auction.package_size_x,
          auction.package_size_y,
          auction.package_size_z
        ].reduce(:*)

        joke = fetch_joke.call

        package_dimension * joke.id
      end
    end
  end
end
