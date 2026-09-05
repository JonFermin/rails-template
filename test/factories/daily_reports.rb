# frozen_string_literal: true

FactoryBot.define do
  factory :daily_report do
    pet
    attendant { pet.location.attendant }
    reported_on { Date.current }
    mood { "happy" }
    nap_minutes { 90 }
    meals { "Ate most of lunch, all of snack." }
    notes { "Played well with the other pets in the yard." }
  end
end
