# frozen_string_literal: true

# Password emails
class PasswordsMailer < ApplicationMailer
  def reset(account)
    @account = account
    mail subject: 'Reset your password', to: account.email_address # rubocop:disable Rails/I18nLocaleTexts
  end
end
