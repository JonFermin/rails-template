# frozen_string_literal: true

require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  test "a pet cannot be checked in twice" do
    pet = create(:pet)
    create(:attendance, pet: pet)

    second = build(:attendance, pet: pet)

    assert_not second.valid?
    assert_includes second.errors[:pet_id], "is already checked in"
  end

  test "a pet can be checked in again after checking out" do
    pet = create(:pet)
    create(:attendance, :closed, pet: pet)

    assert build(:attendance, pet: pet).valid?
  end

  test "check-out must come after check-in" do
    attendance = build(:attendance, checked_in_at: Time.current, checked_out_at: 1.hour.ago)

    assert_not attendance.valid?
    assert_includes attendance.errors[:checked_out_at], "must be after check-in"
  end

  test "closing records the check-out time" do
    attendance = create(:attendance)

    freeze_time do
      attendance.close
      assert_equal Time.current, attendance.reload.checked_out_at
    end
    assert_not attendance.open?
  end
end
