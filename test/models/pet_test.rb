# frozen_string_literal: true

require "test_helper"

class PetTest < ActiveSupport::TestCase
  test "reaches its attendant through the location" do
    pet = create(:pet)

    assert_equal pet.location.attendant, pet.attendant
  end

  test "is linked to owners through ownerships" do
    owner = create(:owner)
    pet = create(:pet, owner: owner)

    assert_equal [ owner ], pet.owners
    assert_equal [ pet ], owner.pets
  end

  test "is checked in while an attendance is open" do
    pet = create(:pet)
    assert_not pet.checked_in?

    attendance = create(:attendance, pet: pet)
    assert pet.checked_in?

    attendance.close
    assert_not pet.checked_in?
  end

  test "requires a name and a birthdate" do
    assert_not build(:pet, name: "").valid?
    assert_not build(:pet, birthdate: nil).valid?
  end
end
