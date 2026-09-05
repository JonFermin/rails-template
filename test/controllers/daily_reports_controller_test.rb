# frozen_string_literal: true

require "test_helper"

class DailyReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @guardian = create(:guardian)
    @child = create(:child, guardian: @guardian)
    @educator = @child.classroom.educator
  end

  test "the educator files a report with photos" do
    sign_in_as(@educator)
    photo = fixture_file_upload("nap.png", "image/png")

    assert_difference("DailyReport.count", 1) do
      post child_daily_reports_path(@child), params: {
        daily_report: { reported_on: Date.current, mood: "calm", nap_minutes: 45, photos: [ photo ] }
      }
    end

    report = DailyReport.last
    assert_redirected_to daily_report_path(report)
    assert_equal @educator, report.educator
    assert_equal 1, report.photos.count
  end

  test "an invalid report is re-rendered with errors" do
    sign_in_as(@educator)

    post child_daily_reports_path(@child), params: { daily_report: { reported_on: Date.current, mood: "ecstatic" } }

    assert_response :unprocessable_entity
    assert_select ".errors li", /Mood/
  end

  test "unexpected attributes are dropped, not assigned" do
    sign_in_as(@educator)

    post child_daily_reports_path(@child), params: {
      daily_report: { reported_on: Date.current, mood: "happy", educator_id: create(:educator).id }
    }

    assert_equal @educator, DailyReport.last.educator
  end

  test "a guardian can read their child's report but not file one" do
    sign_in_as(@guardian)
    report = create(:daily_report, child: @child)

    get daily_report_path(report)
    assert_response :success

    get new_child_daily_report_path(@child)
    assert_response :see_other
  end

  test "a report for someone else's child is a 404" do
    sign_in_as(@guardian)

    get daily_report_path(create(:daily_report))

    assert_response :not_found
  end
end
