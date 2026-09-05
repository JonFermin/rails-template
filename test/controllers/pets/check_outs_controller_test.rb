# frozen_string_literal: true

require "test_helper"

module Pets
  class CheckOutsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @pet = create(:pet, :with_owner)
      @attendant = @pet.location.attendant
    end

    test "the location attendant checks a pet out" do
      attendance = create(:attendance, pet: @pet)
      sign_in_as(@attendant)

      post pet_check_out_path(@pet)

      assert_redirected_to pet_path(@pet)
      assert_not attendance.reload.open?
    end

    test "checking out a pet who is not checked in is a 404" do
      sign_in_as(@attendant)

      post pet_check_out_path(@pet)

      assert_response :not_found
    end
  end
end
