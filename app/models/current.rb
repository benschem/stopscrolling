# frozen_string_literal: true

# Whose request this is. Set once per request by SessionManagement, so user is never nil inside
# one, even for a visitor who has never been here before.
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user

  delegate :account, to: :user, allow_nil: true
end
