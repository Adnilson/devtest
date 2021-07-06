# frozen_string_literal: true

require "simplecov"
SimpleCov.start

ENV["APP_ENV"] = "test"

require "active_support/testing/time_helpers"
require "dry/monads/result"
require_relative "../config/application"
require "vcr"


RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:active_record]
    DatabaseCleaner.strategy = :truncation
  end

  config.before do
    DatabaseCleaner[:active_record]
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:active_record].start
  end

  config.after do
    DatabaseCleaner[:active_record].clean
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
end
