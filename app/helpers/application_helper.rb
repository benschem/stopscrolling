# frozen_string_literal: true

module ApplicationHelper
  def random_cta
    CALL_TO_ACTION_PHRASES.sample
  end

  # The answer plate is painted one of four enamel colours, so a new draw looks like a
  # new sign. A stable number per name picks it in CSS alone, with no motion involved.
  def draw_index(activity)
    return 0 if activity.nil?

    activity.name.sum % 4
  end

  # dom_id derives from to_key, which is nil until a record is saved, so every unsaved
  # activity would share one id. The name is already unique within a list.
  def activity_dom_id(activity)
    "activity_#{activity.name.parameterize}"
  end
end
