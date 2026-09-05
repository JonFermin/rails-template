# frozen_string_literal: true

require "application_system_test_case"

class RequestingActivitySummariesTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test "an owner requests a summary and reads it once the job has run" do
    owner = create(:owner)
    report = create(:daily_report, pet: create(:pet, owner: owner))
    sign_in_through_form(owner)

    click_on report.pet.name
    click_on report.reported_on.to_fs(:long)
    assert_text "No summary yet."

    click_on "Generate summary"
    assert_selector ".flash-notice", text: "Summary is on its way."

    # The request only enqueues; run the job here against the cassette, then reload to read the recap.
    VCR.use_cassette("ai/daily_summary") { perform_enqueued_jobs }
    visit daily_report_path(report)
    within("#activity_summary") do
      assert_text "It was a happy day."
      assert_selector "li", count: 3
    end
  end
end
