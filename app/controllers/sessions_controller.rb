# frozen_string_literal: true

# User sessions
class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
    redirect_to new_session_url, alert: 'Try again later.' # rubocop:disable Rails/I18nLocaleTexts
  }

  def new; end

  def create
    user = User.authenticate_by(session_params.to_h)
    if user
      start_new_session_for user
      redirect_to after_authentication_url, notice: 'Signed in successfully!' # rubocop:disable Rails/I18nLocaleTexts
    else
      flash.now[:alert] = 'Sign in failed.' # rubocop:disable Rails/I18nLocaleTexts
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def session_params
    params.permit(%i[email_address password])
  end
end
