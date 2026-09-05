# frozen_string_literal: true

require "test_helper"

class DailyReportPolicyTest < ActiveSupport::TestCase
  setup do
    @guardian = create(:guardian)
    @report = create(:daily_report, child: create(:child, guardian: @guardian))
    @educator = @report.educator
  end

  test "a guardian can read and request a summary for their own child's report" do
    policy = DailyReportPolicy.new(@guardian, @report)

    assert policy.show?
    assert policy.summarize?
    assert_not policy.create?
  end

  test "the classroom educator can write reports" do
    assert DailyReportPolicy.new(@educator, @report).create?
    assert_not DailyReportPolicy.new(create(:educator), @report).create?
  end

  test "a stranger sees nothing" do
    stranger = create(:guardian)

    assert_not DailyReportPolicy.new(stranger, @report).show?
    assert_empty DailyReportPolicy::Scope.new(stranger, DailyReport).resolve
  end
end
