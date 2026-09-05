# frozen_string_literal: true

require "test_helper"

class ActivitySummariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = create(:owner)
    @report = create(:daily_report, pet: create(:pet, owner: @owner))
  end

  test "an owner asks for a summary and the job is queued" do
    sign_in_as(@owner)

    assert_enqueued_with(job: ActivitySummaryJob, args: [ @report ]) do
      post daily_report_activity_summary_path(@report)
    end

    assert_redirected_to daily_report_path(@report)
  end

  test "nobody can request a summary for a report they cannot see" do
    sign_in_as(create(:owner))

    assert_no_enqueued_jobs do
      post daily_report_activity_summary_path(@report)
    end

    assert_response :not_found
  end
end
