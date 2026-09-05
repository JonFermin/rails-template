# frozen_string_literal: true

# LLM-written recap of a DailyReport. Persisted only after the response passed schema validation in Ai::Completion.
class ActivitySummary < ApplicationRecord
  include Broadcastable

  BODY_MAX_LENGTH = 600
  HIGHLIGHTS_MAX = 3

  belongs_to :daily_report
  delegate :pet, to: :daily_report

  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }
  validates :daily_report_id, uniqueness: true
  validate :highlights_within_limit

  private
    def highlights_within_limit
      return if highlights.size <= HIGHLIGHTS_MAX

      errors.add(:highlights, "can have at most #{HIGHLIGHTS_MAX} entries")
    end
end
