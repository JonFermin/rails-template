# frozen_string_literal: true

FactoryBot.define do
  factory :owner do
    sequence(:email_address) { |n| "owner#{n}@example.com" }
    sequence(:name) { |n| "Owner #{n}" }
    password { "password" }
  end

  factory :attendant do
    sequence(:email_address) { |n| "attendant#{n}@example.com" }
    sequence(:name) { |n| "Attendant #{n}" }
    password { "password" }
  end
end
