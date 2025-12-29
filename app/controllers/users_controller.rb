# frozen_string_literal: true

# User accounts
class UsersController < ApplicationController
  allow_unauthenticated_access

  before_action :delete_expired_unverified_user, only: [:create]

  rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
    redirect_to new_user_url, alert: 'Try again later.' # rubocop:disable Rails/I18nLocaleTexts
  }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: 'Account created!' # rubocop:disable Rails/I18nLocaleTexts
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: %i[email_address password])
  end

  def delete_expired_unverified_user
    existing_user = User.find_by(email_address: user_params[:email_address])
    existing_user.destroy if existing_user&.unverified? && existing_user.verification_expired?
  end
end
