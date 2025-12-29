# frozen_string_literal: true

# Verify a user's email address
class VerifyEmailAddressesController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  rate_limit to: 10, within: 3.minutes, only: :resend, with: lambda {
    redirect_to root_path, alert: 'Try again later.' # rubocop:disable Rails/I18nLocaleTexts
  }

  def show
    user = User.find_by_token_for(:email_address_verification, params[:format])

    if user&.verified?
      redirect_to root_path, notice: 'Email address is already verified.' # rubocop:disable Rails/I18nLocaleTexts
    elsif user&.verify!
      redirect_to root_path, notice: 'Email address verified successfully.' # rubocop:disable Rails/I18nLocaleTexts
    else
      redirect_to root_path, alert: 'Something went wrong. Please try again.' # rubocop:disable Rails/I18nLocaleTexts
    end
  end

  def resend
    if current_user&.unverified?
      UserMailer.verify_email_address(current_user).deliver_later
      redirect_to root_path, notice: 'Verification email resent.' # rubocop:disable Rails/I18nLocaleTexts
    elsif current_user&.verified?
      redirect_to root_path, alert: 'Email address is already verified.' # rubocop:disable Rails/I18nLocaleTexts
    else
      redirect_to root_path, alert: 'You must be signed in.' # rubocop:disable Rails/I18nLocaleTexts
    end
  end
end
