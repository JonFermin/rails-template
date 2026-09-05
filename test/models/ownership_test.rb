# frozen_string_literal: true

require "test_helper"

class OwnershipTest < ActiveSupport::TestCase
  test "links an owner to a pet once" do
    ownership = create(:ownership)
    duplicate = build(:ownership, pet: ownership.pet, owner: ownership.owner)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:owner_id], "has already been taken"
  end

  test "only accepts a known relationship" do
    assert_not build(:ownership, relationship: "neighbor").valid?
    assert build(:ownership, relationship: "co_owner").valid?
  end
end
