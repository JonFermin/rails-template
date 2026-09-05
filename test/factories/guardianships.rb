# frozen_string_literal: true

FactoryBot.define do
  factory :guardianship do
    child
    guardian
    relationship { "parent" }
  end
end
