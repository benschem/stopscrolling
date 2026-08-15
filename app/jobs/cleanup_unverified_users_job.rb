# frozen_string_literal: true

# Delete accounts and their activities if they don't verify their email address
class CleanupUnverifiedUsersJob < ApplicationJob
  queue_as :maintenance

  def perform
    Account.still_unverified_after_grace_period.find_each { |account| account.user.destroy! }
  end
end
