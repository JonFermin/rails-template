# frozen_string_literal: true

require "application_system_test_case"

class SigningInTest < ApplicationSystemTestCase
  test "an owner signs in and sees only their own pets" do
    owner = create(:owner)
    mine = create(:pet, name: "Ada", owner: owner)
    create(:pet, name: "Grace", owner: create(:owner))

    sign_in_through_form(owner)

    assert_selector "h1", text: "Pets"
    assert_link mine.name
    assert_no_text "Grace"
  end

  test "a wrong password bounces back to the form" do
    owner = create(:owner)

    sign_in_through_form(owner, password: "nope")

    assert_selector ".flash-alert", text: "Try another email address or password."
    assert_field "email_address"
  end
end
