# frozen_string_literal: true

require "test_helper"

module Ai
  class CompletionTest < ActiveSupport::TestCase
    SCHEMA = DailySummaryGenerator::SCHEMA
    PROMPT = { system: "<system prompt>", user: "<prompt>" }.freeze

    test "returns the parsed, schema-valid response" do
      VCR.use_cassette("ai/daily_summary") do
        response = Completion.new(PROMPT, schema: SCHEMA).call

        assert_equal %w[ summary highlights ], response.keys
        assert_equal 3, response["highlights"].size
      end
    end

    test "refuses to return a response that does not match the schema" do
      VCR.use_cassette("ai/malformed") do
        error = assert_raises(InvalidResponse) { Completion.new(PROMPT, schema: SCHEMA).call }

        assert_match(/failed schema/, error.message)
        assert_no_match(/script/, error.message, "response content must not leak into the error")
      end
    end

    test "raises when the provider declines to answer" do
      VCR.use_cassette("ai/refusal") do
        assert_raises(Refused) { Completion.new(PROMPT, schema: SCHEMA).call }
      end
    end

    test "stops calling the provider once the daily budget is spent" do
      store = ActiveSupport::Cache::MemoryStore.new
      store.write(Completion::BUDGET_KEY, Rails.configuration.ai[:daily_call_limit])

      # No cassette: reaching the network here would be an error in itself.
      assert_raises(BudgetExhausted) { Completion.new(PROMPT, schema: SCHEMA, store: store).call }
    end

    test "wraps provider failures so callers never see vendor classes" do
      stub_request(:post, "https://api.anthropic.com/v1/messages").to_return(status: 500, body: "{}")

      assert_raises(ProviderError) { Completion.new(PROMPT, schema: SCHEMA).call }
    end

    test "logs token usage but never the prompt or the response" do
      VCR.use_cassette("ai/daily_summary") do
        lines = capture_log { Completion.new(PROMPT, schema: SCHEMA).call }

        assert_match(/ai\.completion .*input_tokens=142 output_tokens=61/, lines)
        assert_no_match(/<prompt>|happy day/, lines)
      end
    end

    private
      def capture_log
        io = StringIO.new
        original, Rails.logger = Rails.logger, ActiveSupport::Logger.new(io)
        yield
        io.string
      ensure
        Rails.logger = original
      end
  end
end
