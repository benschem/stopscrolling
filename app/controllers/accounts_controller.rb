# frozen_string_literal: true

# Signing up for an account
class AccountsController < ApplicationController
  allow_signed_out_access

  before_action :require_signed_out
  before_action :delete_expired_unverified_account, only: [:create]

  rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
    redirect_to new_account_url, alert: 'Try again later.', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
  }

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)
    @account.user = Current.user

    if @account.save
      sign_in_to @account
      redirect_to after_sign_in_url, notice: 'Account created!', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def account_params
    params.expect(account: %i[email_address password])
  end

  def delete_expired_unverified_account
    existing_account = Account.find_by(email_address: account_params[:email_address])
    existing_account.user.destroy if existing_account&.unverified? && existing_account.verification_expired?
  end
end
