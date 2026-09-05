# frozen_string_literal: true

require "test_helper"

class PetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = create(:owner)
    @pet = create(:pet, owner: @owner)
    @other_pet = create(:pet, :with_owner)
  end

  test "an owner sees only their own pets" do
    sign_in_as(@owner)

    get pets_path

    assert_response :success
    assert_select "#pets li", count: 1
    assert_select "#pets li", text: /#{@pet.name}/
  end

  test "an owner can open their pet's page and subscribe to its updates" do
    sign_in_as(@owner)
    create(:activity_summary, daily_report: create(:daily_report, pet: @pet))

    get pet_path(@pet)

    assert_response :success
    assert_select "turbo-cable-stream-source", count: 1
    assert_select ".activity-summary", count: 1
    assert_select "form[action=?]", pet_check_in_path(@pet), count: 0
  end

  test "another owner's pet is indistinguishable from a missing one" do
    sign_in_as(@owner)

    get pet_path(@other_pet)

    assert_response :not_found
  end

  test "an attendant sees the attendance controls for their location" do
    sign_in_as(@pet.location.attendant)

    get pet_path(@pet)

    assert_response :success
    assert_select "form[action=?]", pet_check_in_path(@pet), count: 1
  end

  test "model output is escaped, never rendered as markup" do
    sign_in_as(@owner)
    report = create(:daily_report, pet: @pet)
    create(:activity_summary, daily_report: report, body: "<script>alert(1)</script>", highlights: [ "<b>bold</b>" ])

    get pet_path(@pet)

    assert_includes response.body, "&lt;script&gt;"
    assert_not_includes response.body, "<script>alert"
    assert_not_includes response.body, "<b>bold</b>"
  end
end
