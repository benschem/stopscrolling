# frozen_string_literal: true

# Email the user to verify their password
class UserMailer < ApplicationMailer
  def verify_email_address(user)
    @user = user
    @token = user.email_address_verification_token
    @user.update!(verification_sent_at: Time.current)
    mail subject: 'Verify your email address', to: user.email_address # rubocop:disable Rails/I18nLocaleTexts
  end
end
