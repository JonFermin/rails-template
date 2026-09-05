# frozen_string_literal: true

FactoryBot.define do
  factory :child do
    sequence(:name) { |n| "Child #{n}" }
    birthdate { 3.years.ago.to_date }
    classroom

    # A child with a linked guardian: create(:child, :with_guardian) or create(:child, guardian: someone)
    transient do
      guardian { nil }
    end

    trait :with_guardian do
      guardian { association :guardian }
    end

    after(:create) do |child, context|
      create(:guardianship, child: child, guardian: context.guardian) if context.guardian
    end
  end
end
