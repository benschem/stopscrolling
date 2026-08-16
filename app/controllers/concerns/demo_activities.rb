# frozen_string_literal: true

# List of demo activities for a visitor with nothing saved.
# The activities live in the session so a visitor does not hit the db.
module DemoActivities
  extend ActiveSupport::Concern

  private

  def build_demo_activities
    return if Current.user.persisted?

    demo_activities.names.each { |name| Current.user.activities.build(name: name) }
  end

  def demo_activities
    DemoActivityList.new(session)
  end
end
