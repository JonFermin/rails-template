# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "a guardian is not an educator and vice versa" do
    assert_predicate build(:guardian), :guardian?
    assert_not_predicate build(:guardian), :educator?
    assert_predicate build(:educator), :educator?
  end

  test "requires a name" do
    assert_not build(:guardian, name: "").valid?
  end
end
