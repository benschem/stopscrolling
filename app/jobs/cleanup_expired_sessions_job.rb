# frozen_string_literal: true

# Delete sessions of people who never came back, so nothing waits on a returning visit
class CleanupExpiredSessionsJob < ApplicationJob
  queue_as :maintenance

  def perform
    deleted_count = Session.expired.delete_all

    Rails.logger.info(
      "CleanupExpiredSessionsJob deleted #{deleted_count} expired #{'session'.pluralize(deleted_count)}"
    )
  end
end
