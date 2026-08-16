# frozen_string_literal: true

# Delete sessions of people who never came back, so nothing waits on a returning visit
class CleanupExpiredSessionsJob < ApplicationJob
  queue_as :maintenance

  def perform
    Session.expired.delete_all
  end
end
