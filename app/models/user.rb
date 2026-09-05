# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true

  def owner? = is_a?(Owner)
  def attendant? = is_a?(Attendant)
end
