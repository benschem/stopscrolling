# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    user
    last_seen_at { Time.current }
    expires_at { Session::EXPIRES_IN.from_now }

    trait :expired do
      expires_at { 1.hour.ago }
    end
  end
end
