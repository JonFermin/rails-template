# frozen_string_literal: true

require "application_system_test_case"

class CheckInsTest < ApplicationSystemTestCase
  test "an attendant checks a pet in and back out" do
    pet = create(:pet)
    sign_in_through_form(pet.location.attendant)

    click_on pet.name
    assert_text "Not checked in"

    click_on "Check in"
    assert_text "Checked in"
    assert_button "Check out"

    click_on "Check out"
    assert_text "Not checked in"
    assert_button "Check in"
  end
end
