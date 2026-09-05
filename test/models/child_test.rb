# frozen_string_literal: true

require "test_helper"

class ChildTest < ActiveSupport::TestCase
  test "reaches its educator through the classroom" do
    child = create(:child)

    assert_equal child.classroom.educator, child.educator
  end

  test "is linked to guardians through guardianships" do
    guardian = create(:guardian)
    child = create(:child, guardian: guardian)

    assert_equal [ guardian ], child.guardians
    assert_equal [ child ], guardian.children
  end

  test "is checked in while an attendance is open" do
    child = create(:child)
    assert_not child.checked_in?

    attendance = create(:attendance, child: child)
    assert child.checked_in?

    attendance.close
    assert_not child.checked_in?
  end

  test "requires a name and a birthdate" do
    assert_not build(:child, name: "").valid?
    assert_not build(:child, birthdate: nil).valid?
  end
end
