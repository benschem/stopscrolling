# frozen_string_literal: true

# Works out who is making this request, before anything decides what they are allowed to do.
#
# Resuming writes nothing. Someone we cannot identify is an unsaved User, and stays unsaved until
# they do something worth saving, which is what keeps a crawler from costing us rows.
module SessionManagement
  extend ActiveSupport::Concern

  include DemoActivities

  included do
    before_action :resume_session
  end

  private

  def resume_session
    Current.session = unexpired_session_from_cookie
    Current.user = Current.session&.user || unsaved_visitor
    Current.session&.renew!
  end

  # Never persisted here. Signing up, or first saving something, is what writes them down.
  def unsaved_visitor
    User.new
  end

  def unexpired_session_from_cookie
    session = find_session_by_cookie
    return session unless session&.expired?

    forget_session(session)
    nil
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def start_session_for(user)
    terminate_session

    Current.user = user
    Current.session = create_session_for(user)
    remember_session(Current.session)
  end

  def create_session_for(user)
    user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      last_seen_at: Time.current,
      expires_at: Session::EXPIRES_IN.from_now
    )
  end

  # Signing in rotates the session through here too, so suggestions are discarded rather than
  # laid over the list of the account being signed in to.
  def terminate_session
    forget_session(Current.session)
    demo_activities.clear
    Current.session = nil
    Current.user = unsaved_visitor
  end

  def remember_session(session)
    cookies.signed.permanent[:session_id] = {
      value: session.id,
      httponly: true,
      same_site: :lax
    }

    session
  end

  def forget_session(session)
    session&.destroy
    cookies.delete(:session_id)
  end
end
