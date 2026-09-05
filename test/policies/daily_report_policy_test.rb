# frozen_string_literal: true

require "test_helper"

class DailyReportPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = create(:owner)
    @report = create(:daily_report, pet: create(:pet, owner: @owner))
    @attendant = @report.attendant
  end

  test "an owner can read and request a summary for their own pet's report" do
    policy = DailyReportPolicy.new(@owner, @report)

    assert policy.show?
    assert policy.summarize?
    assert_not policy.create?
  end

  test "the location attendant can write reports" do
    assert DailyReportPolicy.new(@attendant, @report).create?
    assert_not DailyReportPolicy.new(create(:attendant), @report).create?
  end

  test "a stranger sees nothing" do
    stranger = create(:owner)

    assert_not DailyReportPolicy.new(stranger, @report).show?
    assert_empty DailyReportPolicy::Scope.new(stranger, DailyReport).resolve
  end
end
