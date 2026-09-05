# frozen_string_literal: true

# Coverage must start before the application loads or nothing is measured. 85% is a hard gate
# (docs/testing-philosophy.md); the suite exits non-zero below it.
require "simplecov"
SimpleCov.start "rails" do
  minimum_coverage 85
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "vcr"
require "webmock/minitest"
require_relative "test_helpers/session_test_helper"

# CI never talks to a real model. Re-record a cassette with:
#   ANTHROPIC_API_KEY=... VCR_RECORD=all bin/rails test test/services/ai
# and check the new file contains only synthetic data before committing it.
VCR.configure do |config|
  config.cassette_library_dir = "test/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.default_cassette_options = {
    record: ENV.fetch("VCR_RECORD", "none").to_sym,
    match_requests_on: %i[ method uri ]
  }
  config.filter_sensitive_data("<ANTHROPIC_API_KEY>") { ENV["ANTHROPIC_API_KEY"] }
end

# One provider client for the whole run; the key is only real when re-recording cassettes.
Ai.client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY", "test-key"), max_retries: 0)

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Process workers (the Rails default): thread workers share Capybara's session and DB connections and deadlock
    # the moment system tests join the run. Windows has no fork — run with PARALLEL_WORKERS=1 there.
    parallelize(workers: :number_of_processors)

    # Each worker writes its own coverage slice; SimpleCov merges them so the 85% gate sees the whole suite.
    parallelize_setup { |worker| SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}" }
    parallelize_teardown { |_worker| SimpleCov.result }
  end
end
