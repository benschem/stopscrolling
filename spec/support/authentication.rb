# frozen_string_literal: true

# The app rolls its own authentication, so specs sign in the same way a person would rather than
# reaching into the session machinery.
module RequestAuthentication
  def sign_in(user)
    post session_url, params: { email_address: user.email_address, password: user.password }
  end
end

# Signing in through the form, the way a person would.
module SystemAuthentication
  def sign_in(user)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_button 'Sign in'
  end
end

RSpec.configure do |config|
  config.include RequestAuthentication, type: :request
  config.include SystemAuthentication, type: :system
end
