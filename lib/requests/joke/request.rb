# frozen_string_literal: true

require "net/http"
require "json"

module Requests
  module Joke
    ENDPOINT = "https://official-joke-api.appspot.com/random_joke"

    class Request
      def initialize; end

      def call
        uri = URI(ENDPOINT)
        response = Net::HTTP.get(uri)
        transform_to_dto(JSON.parse(response))
      end

      private

      def transform_to_dto(response)
        DTO::Joke.new(response)
      end
    end
  end
end
