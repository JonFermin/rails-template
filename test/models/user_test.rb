# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "an owner is not an attendant and vice versa" do
    assert_predicate build(:owner), :owner?
    assert_not_predicate build(:owner), :attendant?
    assert_predicate build(:attendant), :attendant?
  end

  test "requires a name" do
    assert_not build(:owner, name: "").valid?
  end
end
