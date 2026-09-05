# frozen_string_literal: true

FactoryBot.define do
  factory :daily_report do
    child
    educator { child.classroom.educator }
    reported_on { Date.current }
    mood { "happy" }
    nap_minutes { 90 }
    meals { "Ate most of lunch, all of snack." }
    notes { "Mentioned a new puppy at home." }
  end
end
