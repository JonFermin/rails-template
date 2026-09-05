# frozen_string_literal: true

require "test_helper"

module Ai
  class DailySummaryGeneratorTest < ActiveSupport::TestCase
    setup { @report = create(:daily_report, notes: "Allergy note that must never leave the app") }

    test "prompt includes only allowlisted fields" do
      payload = DailySummaryGenerator.new(@report).prompt_payload

      assert_equal %i[ mood nap_minutes meals ], payload.keys
      assert_no_match(/Allergy/, payload.to_json)
      assert_no_match(/#{@report.pet.name}/, payload.to_json)
    end

    test "creates an activity summary from the model's response" do
      VCR.use_cassette("ai/daily_summary") do
        summary = DailySummaryGenerator.new(@report).call

        assert_predicate summary, :persisted?
        assert_equal @report, summary.daily_report
        assert_match(/happy day/, summary.body)
        assert_equal [ "Napped 90 minutes", "Ate most of lunch", "Finished snack" ], summary.highlights
      end
    end

    test "persists nothing when the response fails validation" do
      VCR.use_cassette("ai/malformed") do
        assert_no_difference("ActivitySummary.count") do
          assert_raises(InvalidResponse) { DailySummaryGenerator.new(@report).call }
        end
      end
    end

    test "the schema sent to the provider is closed to extra properties" do
      assert_equal false, DailySummaryGenerator::SCHEMA["additionalProperties"]
      assert_equal %w[ summary highlights ], DailySummaryGenerator::SCHEMA["required"]
    end
  end
end
