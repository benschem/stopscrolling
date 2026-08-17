# frozen_string_literal: true

# Activities suggested to visitors with nothing saved.
#
# They live in the Rails session rather than the database, so a visitor sees the
# same activities until they close the tab.
class DemoActivityList
  KEY = :demo_activity_names
  SIZE = 5

  def initialize(session)
    @session = session
  end

  def names
    refill_if_empty

    session[KEY]
  end

  def remove(name)
    session[KEY] = names - [name]
  end

  def clear
    session.delete(KEY)
  end

  private

  attr_reader :session

  # As a visitor, deleting all activities gets you a fresh set, not an empty list
  def refill_if_empty
    session[KEY] = SEEDED_ACTIVITIES.sample(SIZE) if session[KEY].blank?
  end
end
