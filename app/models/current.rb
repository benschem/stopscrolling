# frozen_string_literal: true

# Current user session
class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true
  delegate :account, to: :user, allow_nil: true
end
