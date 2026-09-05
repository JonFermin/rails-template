# frozen_string_literal: true

require "test_helper"

class ChildPolicyTest < ActiveSupport::TestCase
  setup do
    @guardian = create(:guardian)
    @child = create(:child, guardian: @guardian)
    @educator = @child.classroom.educator
  end

  test "a guardian can see their own child but nobody else's" do
    other_child = create(:child, :with_guardian)

    assert ChildPolicy.new(@guardian, @child).show?
    assert_not ChildPolicy.new(@guardian, other_child).show?
  end

  test "a guardian cannot record attendance or reports" do
    policy = ChildPolicy.new(@guardian, @child)

    assert_not policy.check_in?
    assert_not policy.check_out?
    assert_not policy.report?
  end

  test "an educator can see and act on children in their classrooms only" do
    other_child = create(:child)

    assert ChildPolicy.new(@educator, @child).show?
    assert ChildPolicy.new(@educator, @child).check_in?
    assert ChildPolicy.new(@educator, @child).report?
    assert_not ChildPolicy.new(@educator, other_child).show?
    assert_not ChildPolicy.new(@educator, other_child).check_in?
  end

  test "the scope only returns children the user is linked to" do
    create(:child, :with_guardian)
    classmate = create(:child, classroom: @child.classroom)

    assert_equal [ @child ], ChildPolicy::Scope.new(@guardian, Child).resolve.to_a
    assert_equal [ @child, classmate ].sort, ChildPolicy::Scope.new(@educator, Child).resolve.sort
  end
end
