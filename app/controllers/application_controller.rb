# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include AccountVerificationWarning
  include DemoActivities

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Expose methods to views
  helper_method :current_user, :current_account

  private

  def current_user
    Current.user
  end

  def current_account
    Current.account
  end
end
