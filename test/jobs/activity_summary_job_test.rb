# frozen_string_literal: true

require "test_helper"

class ActivitySummaryJobTest < ActiveJob::TestCase
  setup { @report = create(:daily_report) }

  test "writes the summary for a report" do
    VCR.use_cassette("ai/daily_summary") do
      ActivitySummaryJob.perform_now(@report)
    end

    assert_predicate @report.reload, :summarized?
  end

  test "does nothing when the report already has a summary" do
    create(:activity_summary, daily_report: @report)

    # No cassette: a second provider call would raise.
    assert_no_changes -> { @report.reload.activity_summary.body } do
      ActivitySummaryJob.perform_now(@report)
    end
  end

  test "is dropped, not retried, when the daily budget is spent" do
    job = ActivitySummaryJob.new(@report)

    job.stub(:perform, ->(*) { raise Ai::BudgetExhausted }) do
      assert_no_enqueued_jobs { job.perform_now }
    end
  end

  test "retries once on a malformed response" do
    VCR.use_cassette("ai/malformed") do
      assert_enqueued_with(job: ActivitySummaryJob, args: [ @report ]) do
        ActivitySummaryJob.perform_now(@report)
      end
    end
  end

  test "runs on its own queue" do
    assert_enqueued_with(job: ActivitySummaryJob, queue: "ai") do
      ActivitySummaryJob.perform_later(@report)
    end
  end
end
