# frozen_string_literal: true

# People can reset forgotten passwords and change their passwords
class PasswordsController < ApplicationController
  RESET_INSTRUCTIONS_SENT = 'Password reset instructions sent.'

  allow_signed_out_access

  before_action :set_account_by_token, only: %i[edit update]

  def new; end

  def edit; end

  def create
    if (account = Account.find_by(email_address: params[:email_address]))
      PasswordsMailer.reset(account).deliver_later
    end

    redirect_to new_session_path, notice: RESET_INSTRUCTIONS_SENT, status: :see_other
  end

  def update
    if @account.update(params.permit(:password, :password_confirmation))
      redirect_to new_session_path, notice: 'Password has been reset.', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
    else
      redirect_to edit_password_path(params[:token]), alert: 'Passwords did not match.', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
    end
  end

  private

  def set_account_by_token
    @account = Account.find_by_token_for!(:password_reset, params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    redirect_to new_password_path, alert: 'Password reset link is invalid or has expired.' # rubocop:disable Rails/I18nLocaleTexts
  end
end
