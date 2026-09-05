# frozen_string_literal: true

require "test_helper"

module Children
  class CheckOutsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @child = create(:child, :with_guardian)
      @educator = @child.classroom.educator
    end

    test "the classroom educator checks a child out" do
      attendance = create(:attendance, child: @child)
      sign_in_as(@educator)

      post child_check_out_path(@child)

      assert_redirected_to child_path(@child)
      assert_not attendance.reload.open?
    end

    test "checking out a child who is not checked in is a 404" do
      sign_in_as(@educator)

      post child_check_out_path(@child)

      assert_response :not_found
    end
  end
end
