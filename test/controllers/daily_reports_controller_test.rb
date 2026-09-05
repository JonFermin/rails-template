# frozen_string_literal: true

require "test_helper"

class DailyReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = create(:owner)
    @pet = create(:pet, owner: @owner)
    @attendant = @pet.location.attendant
  end

  test "the attendant files a report with photos" do
    sign_in_as(@attendant)
    photo = fixture_file_upload("nap.png", "image/png")

    assert_difference("DailyReport.count", 1) do
      post pet_daily_reports_path(@pet), params: {
        daily_report: { reported_on: Date.current, mood: "calm", nap_minutes: 45, photos: [ photo ] }
      }
    end

    report = DailyReport.last
    assert_redirected_to daily_report_path(report)
    assert_equal @attendant, report.attendant
    assert_equal 1, report.photos.count
  end

  test "an invalid report is re-rendered with errors" do
    sign_in_as(@attendant)

    post pet_daily_reports_path(@pet), params: { daily_report: { reported_on: Date.current, mood: "ecstatic" } }

    assert_response :unprocessable_entity
    assert_select ".errors li", /Mood/
  end

  test "unexpected attributes are dropped, not assigned" do
    sign_in_as(@attendant)

    post pet_daily_reports_path(@pet), params: {
      daily_report: { reported_on: Date.current, mood: "happy", attendant_id: create(:attendant).id }
    }

    assert_equal @attendant, DailyReport.last.attendant
  end

  test "an owner can read their pet's report but not file one" do
    sign_in_as(@owner)
    report = create(:daily_report, pet: @pet)

    get daily_report_path(report)
    assert_response :success

    get new_pet_daily_report_path(@pet)
    assert_response :see_other
  end

  test "a report for someone else's pet is a 404" do
    sign_in_as(@owner)

    get daily_report_path(create(:daily_report))

    assert_response :not_found
  end
end
