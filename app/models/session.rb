# frozen_string_literal: true

# One browser, identified by a signed cookie
class Session < ApplicationRecord
  EXPIRES_IN = 2.weeks

  belongs_to :user

  def expired?
    expires_at <= Time.current
  end

  def renew!
    update_columns( # rubocop:disable Rails/SkipsModelValidations
      last_seen_at: Time.current,
      expires_at: EXPIRES_IN.from_now
    )
  end
end
