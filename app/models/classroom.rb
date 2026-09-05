# frozen_string_literal: true

class Classroom < ApplicationRecord
  belongs_to :educator
  has_many :children, dependent: :restrict_with_error

  validates :name, presence: true
end
