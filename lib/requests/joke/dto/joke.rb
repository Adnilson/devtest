# frozen_string_literal: true

module Requests
  module Joke
    module DTO
      class Joke
        attr_reader :id, :type, :setup, :punchline

        def initialize(data)
          @id        = data["id"]
          @type      = data["type"]
          @setup     = data["setup"]
          @punchline = data["punchline"]
        end
      end
    end
  end
end
