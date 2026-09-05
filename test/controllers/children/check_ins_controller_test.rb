# frozen_string_literal: true

require "test_helper"

module Children
  class CheckInsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @child = create(:child, :with_guardian)
      @educator = @child.classroom.educator
    end

    test "the classroom educator checks a child in" do
      sign_in_as(@educator)

      assert_difference("Attendance.open.count", 1) do
        post child_check_in_path(@child)
      end

      assert_redirected_to child_path(@child)
      assert @child.reload.checked_in?
    end

    test "a guardian cannot check their child in" do
      sign_in_as(@child.guardians.first)

      assert_no_difference("Attendance.count") do
        post child_check_in_path(@child)
      end

      assert_response :see_other
    end

    test "an educator from another classroom gets a 404" do
      sign_in_as(create(:educator))

      post child_check_in_path(@child)

      assert_response :not_found
    end
  end
end
