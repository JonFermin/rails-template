# frozen_string_literal: true

class Location < ApplicationRecord
  belongs_to :attendant
  has_many :pets, dependent: :restrict_with_error

  validates :name, presence: true
end
