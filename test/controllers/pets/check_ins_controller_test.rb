# frozen_string_literal: true

require "test_helper"

module Pets
  class CheckInsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @pet = create(:pet, :with_owner)
      @attendant = @pet.location.attendant
    end

    test "the location attendant checks a pet in" do
      sign_in_as(@attendant)

      assert_difference("Attendance.open.count", 1) do
        post pet_check_in_path(@pet)
      end

      assert_redirected_to pet_path(@pet)
      assert @pet.reload.checked_in?
    end

    test "an owner cannot check their pet in" do
      sign_in_as(@pet.owners.first)

      assert_no_difference("Attendance.count") do
        post pet_check_in_path(@pet)
      end

      assert_response :see_other
    end

    test "an attendant from another location gets a 404" do
      sign_in_as(create(:attendant))

      post pet_check_in_path(@pet)

      assert_response :not_found
    end
  end
end
