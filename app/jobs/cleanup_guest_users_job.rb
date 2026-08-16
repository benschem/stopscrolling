# frozen_string_literal: true

# Delete guests and their activities once nothing can reach them any more
class CleanupGuestUsersJob < ApplicationJob
  queue_as :maintenance

  def perform
    deleted_count = 0

    User.abandoned_guests.find_each do |guest|
      guest.destroy!
      deleted_count += 1
    end

    Rails.logger.info(
      "CleanupGuestUsersJob deleted #{deleted_count} abandoned #{'guest'.pluralize(deleted_count)}"
    )
  end
end
