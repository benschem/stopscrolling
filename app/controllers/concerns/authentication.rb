# frozen_string_literal: true

# Whether this request is allowed through, once the session has said who is asking.
# Including SessionManagement is what guarantees the session is resumed before the gate asks
# about it, rather than the two callbacks relying on declaration order.
module Authentication
  extend ActiveSupport::Concern

  include SessionManagement

  included do
    before_action :require_sign_in

    helper_method :signed_in?
  end

  class_methods do
    def allow_signed_out_access(**options)
      skip_before_action :require_sign_in, **options
    end
  end

  private

  def signed_in?
    Current.user&.signed_up?
  end

  def require_sign_in
    request_sign_in unless signed_in?
  end

  def request_sign_in
    session[:return_to_after_signing_in] = request.url

    respond_to do |format|
      format.html { redirect_to new_session_path }
      format.turbo_stream { head :unauthorized } # prevents redirect
    end
  end

  def after_sign_in_url
    session.delete(:return_to_after_signing_in) || root_url
  end

  def sign_in_to(account)
    start_session_for(account.user)
  end
end
