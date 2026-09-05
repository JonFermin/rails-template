# frozen_string_literal: true

require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  test "a child cannot be checked in twice" do
    child = create(:child)
    create(:attendance, child: child)

    second = build(:attendance, child: child)

    assert_not second.valid?
    assert_includes second.errors[:child_id], "is already checked in"
  end

  test "a child can be checked in again after checking out" do
    child = create(:child)
    create(:attendance, :closed, child: child)

    assert build(:attendance, child: child).valid?
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
