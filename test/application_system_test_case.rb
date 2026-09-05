# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
    # Chrome's "save password?" bubble steals input focus after sign-in, silently swallowing every later click.
    options.add_preference(:credentials_enable_service, false)
    options.add_preference("profile.password_manager_enabled", false)
    options.add_preference("profile.password_manager_leak_detection", false)
  end

  # Waits for the landing page so callers never race the redirect (docs/testing-philosophy.md → no flaky tolerance).
  def sign_in_through_form(user, password: "password")
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_on "Sign in"
    assert_selector "h1", text: "Pets" if user.authenticate(password)
  end
end
