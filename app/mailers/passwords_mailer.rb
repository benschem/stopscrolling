# frozen_string_literal: true

# Password emails
class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: 'Reset your password', to: user.email_address # rubocop:disable Rails/I18nLocaleTexts
  end
end
