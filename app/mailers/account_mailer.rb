# frozen_string_literal: true

# Emails about signing in and account verification
class AccountMailer < ApplicationMailer
  def verify_email_address(account)
    @account = account
    @token = account.email_address_verification_token
    @account.update!(verification_sent_at: Time.current)
    mail subject: 'Verify your email address', to: account.email_address # rubocop:disable Rails/I18nLocaleTexts
  end
end
