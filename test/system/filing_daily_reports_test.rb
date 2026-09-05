# frozen_string_literal: true

require "application_system_test_case"

class FilingDailyReportsTest < ApplicationSystemTestCase
  test "an attendant files a daily report from the pet's page" do
    pet = create(:pet)
    sign_in_through_form(pet.location.attendant)

    click_on pet.name
    assert_selector "h1", text: pet.name
    click_on "New daily report"
    assert_selector "h1", text: "New daily report"

    fill_in "Reported on", with: Date.current
    select "tired", from: "Mood"
    fill_in "Nap minutes", with: 40
    fill_in "Meals", with: "Half of lunch"
    click_on "Save report"

    assert_selector "h1", text: "Daily report for #{Date.current.to_fs(:long)}"
    assert_text "tired"
    assert_text "40 minutes"
    assert_text "Half of lunch"
  end
end
