# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    trait :signed_up do
      account
    end
  end
end
