# frozen_string_literal: true

FactoryBot.define do
  factory :pet do
    sequence(:name) { |n| "Pet #{n}" }
    birthdate { 3.years.ago.to_date }
    location

    # A pet with a linked owner: create(:pet, :with_owner) or create(:pet, owner: someone)
    transient do
      owner { nil }
    end

    trait :with_owner do
      owner { association :owner }
    end

    after(:create) do |pet, context|
      create(:ownership, pet: pet, owner: context.owner) if context.owner
    end
  end
end
