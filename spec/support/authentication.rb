# frozen_string_literal: true

# The app rolls its own authentication, so specs sign in the same way a person would rather than
# reaching into the session machinery.
module RequestAuthentication
  def sign_in(account)
    post session_url, params: { email_address: account.email_address, password: account.password }
  end

  def sign_up(email_address:, password: 'secret123')
    post accounts_url, params: { account: { email_address: email_address, password: password } }
  end
end

# Signing in through the form, the way a person would.
module SystemAuthentication
  def sign_in(account)
    visit new_session_path
    fill_in 'email_address', with: account.email_address
    fill_in 'password', with: account.password
    click_button 'Sign in'
  end
end

RSpec.configure do |config|
  config.include RequestAuthentication, type: :request
  config.include SystemAuthentication, type: :system
end
