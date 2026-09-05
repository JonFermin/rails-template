# frozen_string_literal: true

FactoryBot.define do
  factory :activity_summary do
    daily_report
    body { "A cheerful day with a solid nap and a good appetite." }
    highlights { [ "Napped 90 minutes", "Finished snack" ] }
  end
end
