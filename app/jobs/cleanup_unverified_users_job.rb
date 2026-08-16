# frozen_string_literal: true

# Delete accounts and their activities if they don't verify their email address
class CleanupUnverifiedUsersJob < ApplicationJob
  queue_as :maintenance

  def perform
    deleted_count = 0

    Account.still_unverified_after_grace_period.find_each do |account|
      account.user.destroy!
      deleted_count += 1
    end

    Rails.logger.info(
      "CleanupUnverifiedUsersJob deleted #{deleted_count} unverified #{'user'.pluralize(deleted_count)}"
    )
  end
end
