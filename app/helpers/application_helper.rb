# frozen_string_literal: true

module ApplicationHelper
  NO_DRAW_HEADLINE = 'Get off your phone and do something else.'

  # The phrase leading up to the activity is the qualifier, the activity is the destination,
  # so that is the part set apart. Built here rather than in the view so the whole headline
  # can be measured before it is set, which is what picks the type size.
  def headline_for(activity)
    return NO_DRAW_HEADLINE if activity.nil?

    safe_join([CALL_TO_ACTION_PHRASES.sample, ' ', tag.strong(activity.name.downcase), '.'])
  end

  # The plate is a fixed height, so a long draw has to give somewhere: the type shrinks
  # rather than the plate growing and walking the buttons down the page. Three tiers is
  # enough, since the qualifiers are all of a length and only the activity really varies.
  def headline_size(headline)
    case strip_tags(headline).length
    when 0..28 then 'short'
    when 29..48 then 'medium'
    else 'long'
    end
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
