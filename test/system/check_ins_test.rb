# frozen_string_literal: true

require "application_system_test_case"

class CheckInsTest < ApplicationSystemTestCase
  test "an educator checks a child in and back out" do
    child = create(:child)
    sign_in_through_form(child.classroom.educator)

    click_on child.name
    assert_text "Not checked in"

    click_on "Check in"
    assert_text "Checked in"
    assert_button "Check out"

    click_on "Check out"
    assert_text "Not checked in"
    assert_button "Check in"
  end
end
