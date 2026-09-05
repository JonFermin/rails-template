# frozen_string_literal: true

FactoryBot.define do
  factory :ownership do
    pet
    owner
    relationship { "primary" }
  end
end
