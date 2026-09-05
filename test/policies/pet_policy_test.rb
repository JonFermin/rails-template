# frozen_string_literal: true

require "test_helper"

class PetPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = create(:owner)
    @pet = create(:pet, owner: @owner)
    @attendant = @pet.location.attendant
  end

  test "an owner can see their own pet but nobody else's" do
    other_pet = create(:pet, :with_owner)

    assert PetPolicy.new(@owner, @pet).show?
    assert_not PetPolicy.new(@owner, other_pet).show?
  end

  test "an owner cannot record attendance or reports" do
    policy = PetPolicy.new(@owner, @pet)

    assert_not policy.check_in?
    assert_not policy.check_out?
    assert_not policy.report?
  end

  test "an attendant can see and act on pets in their locations only" do
    other_pet = create(:pet)

    assert PetPolicy.new(@attendant, @pet).show?
    assert PetPolicy.new(@attendant, @pet).check_in?
    assert PetPolicy.new(@attendant, @pet).report?
    assert_not PetPolicy.new(@attendant, other_pet).show?
    assert_not PetPolicy.new(@attendant, other_pet).check_in?
  end

  test "the scope only returns pets the user is linked to" do
    create(:pet, :with_owner)
    classmate = create(:pet, location: @pet.location)

    assert_equal [ @pet ], PetPolicy::Scope.new(@owner, Pet).resolve.to_a
    assert_equal [ @pet, classmate ].sort, PetPolicy::Scope.new(@attendant, Pet).resolve.sort
  end
end
