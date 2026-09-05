# frozen_string_literal: true

# One check-in/check-out pair. Check-in creates the row; check-out closes it.
class Attendance < ApplicationRecord
  belongs_to :child
  belongs_to :educator

  scope :open, -> { where(checked_out_at: nil) }

  validates :checked_in_at, presence: true
  validates :child_id, uniqueness: { conditions: -> { open }, message: "is already checked in" }, on: :create
  validate :checked_out_after_checked_in

  def open?
    checked_out_at.nil?
  end

  def close(at: Time.current)
    update(checked_out_at: at)
  end

  private
    def checked_out_after_checked_in
      return if checked_out_at.blank? || checked_in_at.blank?
      return if checked_out_at > checked_in_at

      errors.add(:checked_out_at, "must be after check-in")
    end
end
