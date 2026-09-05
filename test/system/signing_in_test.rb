# frozen_string_literal: true

require "application_system_test_case"

class SigningInTest < ApplicationSystemTestCase
  test "a guardian signs in and sees only their own children" do
    guardian = create(:guardian)
    mine = create(:child, name: "Ada", guardian: guardian)
    create(:child, name: "Grace", guardian: create(:guardian))

    sign_in_through_form(guardian)

    assert_selector "h1", text: "Children"
    assert_link mine.name
    assert_no_text "Grace"
  end

  test "a wrong password bounces back to the form" do
    guardian = create(:guardian)

    sign_in_through_form(guardian, password: "nope")

    assert_selector ".flash-alert", text: "Try another email address or password."
    assert_field "email_address"
  end
end
