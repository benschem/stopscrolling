# frozen_string_literal: true

# User authentication
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :update_session_last_seen_at_and_expires_at, if: :user_signed_in?

    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      skip_before_action :update_session_last_seen_at_and_expires_at, **options
    end
  end

  private

  def user_signed_in?
    Current.user.present?
  end

  def authenticated?
    resume_session
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    session = find_session_by_cookie
    return false unless session

    if session.expires_at <= Time.zone.now
      session.destroy
      return false
    end

    Current.session = session
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url

    respond_to do |format|
      format.html { redirect_to new_session_path }
      format.turbo_stream { head :unauthorized } # prevents redirect
    end
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    create_session(user).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = {
        value: session.id,
        httponly: true,
        same_site: :lax
      }
    end
  end

  def create_session(user)
    user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      last_seen_at: Time.zone.now,
      expires_at: 2.weeks.from_now
    )
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
  end

  def update_session_last_seen_at_and_expires_at
    return unless Current.session

    # Using update_columns is faster when there's no need to run validations
    Current.session.update_columns( # rubocop:disable Rails/SkipsModelValidations
      last_seen_at: Time.current,
      expires_at: 2.weeks.from_now
    )
  end
end
