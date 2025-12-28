# frozen_string_literal: true

# User
class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :activities, dependent: :destroy

  normalizes :email_address, with: ->(email) { email&.strip&.downcase }

  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: 'must be a valid email address' # rubocop:disable Rails/I18nLocaleTexts
            }
end
