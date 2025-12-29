# frozen_string_literal: true

# Verify a user's email address with a token that can be sent in an email and used to find the user
module EmailAddressVerification
  extend ActiveSupport::Concern

  TOKEN_EXPIRES_IN = 24.hours

  included do
    generates_token_for :email_address_verification, expires_in: TOKEN_EXPIRES_IN

    after_commit :require_email_address_verification, if: :requires_email_verification?, on: %i[create update]

    scope :too_long_without_verifying, -> { where(verified_at: nil).where(verification_sent_at: ...7.days.ago) }
    # TODO: implement periodic clean up job -> User.too_long_without_verifying.destroy_all!
    # Not urgent because users can reclaim unverified email addresses -> see controller
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
    !skip_email_verification && new_user_or_email_address_updated?
  end

  def new_user_or_email_address_updated?
    !persisted? || saved_change_to_email_address?
  end

  def require_email_address_verification
    return unless persisted?

    # Use update_column because this runs inside after_commit
    update_column(:verified_at, nil) # rubocop:disable Rails/SkipsModelValidations
    UserMailer.verify_email_address(self).deliver_later!
  end
end
