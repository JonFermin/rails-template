# frozen_string_literal: true

FactoryBot.define do
  factory :classroom do
    sequence(:name) { |n| "Room #{n}" }
    educator
  end
end
