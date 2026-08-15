# frozen_string_literal: true

# Verify an account's email address with a token that can be emailed and used to find the account
module EmailAddressVerification
  extend ActiveSupport::Concern

  TOKEN_EXPIRES_IN = 24.hours
  UNVERIFIED_GRACE_PERIOD = 7.days

  included do
    generates_token_for :email_address_verification, expires_in: TOKEN_EXPIRES_IN

    after_commit :require_email_address_verification, if: :requires_email_verification?, on: %i[create update]

    scope :still_unverified_after_grace_period, lambda {
      where(verified_at: nil)
        .where(created_at: ...UNVERIFIED_GRACE_PERIOD.ago)
        .includes(user: :activities)
    }
  end

  def email_address_verification_token
    generate_token_for(:email_address_verification)
  end

  def verify!
    return false if verification_expired? || verified?

    update!(verified_at: Time.current)
  end

  def verified?
    verified_at.present?
  end

  def unverified?
    verified_at.nil?
  end

  def verification_expired?
    return false unless verification_sent_at

    expires_at = verification_sent_at + EmailAddressVerification::TOKEN_EXPIRES_IN
    Time.current > expires_at
  end

  private

  def requires_email_verification?
    !skip_email_verification && new_account_or_email_address_updated?
  end

  def new_account_or_email_address_updated?
    !persisted? || saved_change_to_email_address?
  end

  def require_email_address_verification
    return unless persisted?

    # Use update_column because this runs inside after_commit
    update_column(:verified_at, nil) # rubocop:disable Rails/SkipsModelValidations
    AccountMailer.verify_email_address(self).deliver_later!
  end
end
