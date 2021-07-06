# frozen_string_literal: true

require "dry/monads/do"
require "net/http"
require "json"

module Orders
  module Actions
    class CalculateShippingCosts
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      class << self
        def call(**kwargs)
          new(**kwargs).call
        end
      end

      def initialize(auction_id:, shipping_method:)
        @auction_id = auction_id
        @shipping_method = shipping_method
      end

      def call
        auction = yield fetch_auction
        shipping_costs = yield calculate_shipping_costs(auction)

        Success(shipping_costs)
      end

      private

      attr_reader :auction_id, :shipping_method

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
        package_weight = auction.package_weight.ceil
        package_weight * 2
      end

      def calculate_ground_shipping(auction)
        package_dimension = [
          auction.package_size_x,
          auction.package_size_y,
          auction.package_size_z
        ].reduce(:*)

        joke = fetch_joke

        package_dimension * joke["id"]
      end

      def fetch_joke
        uri = URI "https://official-joke-api.appspot.com/random_joke"
        JSON.parse(Net::HTTP.get(uri))
      end
    end
  end
end
