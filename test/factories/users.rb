# frozen_string_literal: true

FactoryBot.define do
  factory :guardian do
    sequence(:email_address) { |n| "guardian#{n}@example.com" }
    sequence(:name) { |n| "Guardian #{n}" }
    password { "password" }
  end

  factory :educator do
    sequence(:email_address) { |n| "educator#{n}@example.com" }
    sequence(:name) { |n| "Educator #{n}" }
    password { "password" }
  end
end
