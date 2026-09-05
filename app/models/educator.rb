# frozen_string_literal: true

class Educator < User
  has_many :classrooms, dependent: :restrict_with_error
  has_many :children, through: :classrooms
  has_many :daily_reports, dependent: :restrict_with_error
end
