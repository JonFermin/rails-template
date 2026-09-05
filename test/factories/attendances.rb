# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    pet
    attendant { pet.location.attendant }
    checked_in_at { 2.hours.ago }

    trait :closed do
      checked_out_at { 1.hour.ago }
    end
  end
end
