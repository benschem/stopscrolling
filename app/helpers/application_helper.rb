# frozen_string_literal: true

module ApplicationHelper
  def random_cta
    CALL_TO_ACTION_PHRASES.sample
  end

  # dom_id derives from to_key, which is nil until a record is saved, so every unsaved
  # activity would share one id. The name is already unique within a list.
  def activity_dom_id(activity)
    "activity_#{activity.name.parameterize}"
  end
end
