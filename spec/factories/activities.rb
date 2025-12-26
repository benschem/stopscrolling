# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    name { Faker::Hobby.unique.activity }

    trait :invalid do
      name { nil }
    end
  end
end
