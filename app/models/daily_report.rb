# frozen_string_literal: true

class DailyReport < ApplicationRecord
  include Broadcastable

  MOODS = %w[ happy calm tired fussy ].freeze
  PHOTO_CONTENT_TYPES = %w[ image/jpeg image/png image/webp ].freeze
  PHOTO_MAX_BYTES = 10.megabytes

  belongs_to :child
  belongs_to :educator
  has_one :activity_summary, dependent: :destroy
  has_many_attached :photos

  validates :reported_on, presence: true, uniqueness: { scope: :child_id }
  validates :mood, inclusion: { in: MOODS }
  validates :nap_minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :photos_are_images_within_limit

  scope :recent_first, -> { order(reported_on: :desc) }

  def summarized?
    activity_summary.present?
  end

  private
    # Photos of minors: only real image types, capped in size — see the upload-validation judgment call in the README.
    def photos_are_images_within_limit
      photos.each do |photo|
        errors.add(:photos, "must be JPEG, PNG or WebP") unless photo.content_type.in?(PHOTO_CONTENT_TYPES)
        errors.add(:photos, "must be under #{PHOTO_MAX_BYTES / 1.megabyte} MB") if photo.byte_size > PHOTO_MAX_BYTES
      end
    end
end
