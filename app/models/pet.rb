# frozen_string_literal: true

# A pet is in the system because an owner enrolled them — Ownership is that consent record, and every
# owner-facing read goes through PetPolicy. Everything hanging off a pet (attendances, reports, photos, summaries)
# is destroyed with it; the retention window is documented in the README, not enforced by a job in this template
# (docs/security-checklist.md → owner-consent / pet-data handling).
class Pet < ApplicationRecord
  belongs_to :location
  has_one :attendant, through: :location
  has_many :ownerships, dependent: :destroy
  has_many :owners, through: :ownerships
  has_many :attendances, dependent: :destroy
  has_many :daily_reports, dependent: :destroy

  validates :name, :birthdate, presence: true

  scope :with_recent_reports, -> { includes(daily_reports: :activity_summary) }

  def checked_in?
    attendances.open.exists?
  end
end
