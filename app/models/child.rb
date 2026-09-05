# frozen_string_literal: true

# A record about a minor. A child is in the system because a guardian enrolled them — Guardianship is that consent
# record, and every guardian-facing read goes through ChildPolicy. Everything hanging off a child (attendances,
# reports, photos, summaries) is destroyed with it; the retention window is documented in the README, not enforced
# by a job in this template (docs/security-checklist.md → COPPA).
class Child < ApplicationRecord
  belongs_to :classroom
  has_one :educator, through: :classroom
  has_many :guardianships, dependent: :destroy
  has_many :guardians, through: :guardianships
  has_many :attendances, dependent: :destroy
  has_many :daily_reports, dependent: :destroy

  validates :name, :birthdate, presence: true

  scope :with_recent_reports, -> { includes(daily_reports: :activity_summary) }

  def checked_in?
    attendances.open.exists?
  end
end
