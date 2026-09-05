# frozen_string_literal: true

require "test_helper"
require "turbo/broadcastable/test_helper"

class DailyReportTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  test "one report per child per day" do
    existing = create(:daily_report)
    duplicate = build(:daily_report, child: existing.child, reported_on: existing.reported_on)

    assert_not duplicate.valid?
  end

  test "mood must be one of the known moods" do
    assert_not build(:daily_report, mood: "ecstatic").valid?
  end

  test "nap minutes cannot be negative" do
    assert_not build(:daily_report, nap_minutes: -5).valid?
  end

  test "photos must be images under the size limit" do
    report = build(:daily_report)
    report.photos.attach(io: StringIO.new("%PDF-1.4"), filename: "notes.pdf", content_type: "application/pdf")

    assert_not report.valid?
    assert_includes report.errors[:photos], "must be JPEG, PNG or WebP"
  end

  test "accepts a small image" do
    report = build(:daily_report)
    report.photos.attach(io: StringIO.new("PNG bytes"), filename: "nap.png", content_type: "image/png")

    assert report.valid?
  end

  test "is summarized once an activity summary exists" do
    report = create(:daily_report)
    assert_not report.summarized?

    create(:activity_summary, daily_report: report)
    assert report.reload.summarized?
  end

  test "saving a report refreshes everyone watching the child" do
    child = create(:child)

    assert_turbo_stream_broadcasts child, count: 1 do
      perform_enqueued_jobs { create(:daily_report, child: child) }
    end
  end
end
