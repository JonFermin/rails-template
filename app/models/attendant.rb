# frozen_string_literal: true

class Attendant < User
  has_many :locations, dependent: :restrict_with_error
  has_many :pets, through: :locations
  has_many :daily_reports, dependent: :restrict_with_error
end
