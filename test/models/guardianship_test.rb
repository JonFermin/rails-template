# frozen_string_literal: true

require "test_helper"

class GuardianshipTest < ActiveSupport::TestCase
  test "links a guardian to a child once" do
    guardianship = create(:guardianship)
    duplicate = build(:guardianship, child: guardianship.child, guardian: guardianship.guardian)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:guardian_id], "has already been taken"
  end

  test "only accepts a known relationship" do
    assert_not build(:guardianship, relationship: "neighbor").valid?
    assert build(:guardianship, relationship: "grandparent").valid?
  end
end
