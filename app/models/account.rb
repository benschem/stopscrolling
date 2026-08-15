# frozen_string_literal: true

# How someone signs in to see the activities they own
class Account < ApplicationRecord
  include EmailAddressVerification

  attr_accessor :skip_email_verification

  belongs_to :user

  has_secure_password

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt&.last(10)
  end

  normalizes :email_address, with: ->(email) { email&.strip&.downcase }

  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: 'must be a valid email address' # rubocop:disable Rails/I18nLocaleTexts
            }
end
