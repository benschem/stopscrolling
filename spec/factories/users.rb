# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    password { Faker::Internet.password }

    trait :verified do
      skip_email_verification { true }
      verified_at { Time.current }
    end
  end
end
