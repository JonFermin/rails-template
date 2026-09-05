# frozen_string_literal: true

require "test_helper"

class ChildrenControllerTest < ActionDispatch::IntegrationTest
  setup do
    @guardian = create(:guardian)
    @child = create(:child, guardian: @guardian)
    @other_child = create(:child, :with_guardian)
  end

  test "a guardian sees only their own children" do
    sign_in_as(@guardian)

    get children_path

    assert_response :success
    assert_select "#children li", count: 1
    assert_select "#children li", text: /#{@child.name}/
  end

  test "a guardian can open their child's page and subscribe to its updates" do
    sign_in_as(@guardian)
    create(:activity_summary, daily_report: create(:daily_report, child: @child))

    get child_path(@child)

    assert_response :success
    assert_select "turbo-cable-stream-source", count: 1
    assert_select ".activity-summary", count: 1
    assert_select "form[action=?]", child_check_in_path(@child), count: 0
  end

  test "another guardian's child is indistinguishable from a missing one" do
    sign_in_as(@guardian)

    get child_path(@other_child)

    assert_response :not_found
  end

  test "an educator sees the attendance controls for their classroom" do
    sign_in_as(@child.classroom.educator)

    get child_path(@child)

    assert_response :success
    assert_select "form[action=?]", child_check_in_path(@child), count: 1
  end

  test "model output is escaped, never rendered as markup" do
    sign_in_as(@guardian)
    report = create(:daily_report, child: @child)
    create(:activity_summary, daily_report: report, body: "<script>alert(1)</script>", highlights: [ "<b>bold</b>" ])

    get child_path(@child)

    assert_includes response.body, "&lt;script&gt;"
    assert_not_includes response.body, "<script>alert"
    assert_not_includes response.body, "<b>bold</b>"
  end
end
