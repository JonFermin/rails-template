# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "Room #{n}" }
    attendant
  end
end
