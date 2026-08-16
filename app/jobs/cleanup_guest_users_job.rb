# frozen_string_literal: true

# Delete guests and their activities once nothing can reach them any more
class CleanupGuestUsersJob < ApplicationJob
  queue_as :maintenance

  def perform
    User.abandoned_guests.find_each(&:destroy!)
  end
end
