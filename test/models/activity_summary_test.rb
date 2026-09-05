# frozen_string_literal: true

require "test_helper"
require "turbo/broadcastable/test_helper"

class ActivitySummaryTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  test "belongs to exactly one report" do
    summary = create(:activity_summary)
    duplicate = build(:activity_summary, daily_report: summary.daily_report)

    assert_not duplicate.valid?
  end

  test "keeps the body and highlights short" do
    assert_not build(:activity_summary, body: "x" * 601).valid?
    assert_not build(:activity_summary, highlights: %w[ a b c d ]).valid?
    assert build(:activity_summary, body: "x" * 600, highlights: %w[ a b c ]).valid?
  end

  test "a new summary refreshes everyone watching the child" do
    report = create(:daily_report)

    assert_turbo_stream_broadcasts report.child, count: 1 do
      perform_enqueued_jobs { create(:activity_summary, daily_report: report) }
    end
  end
end
