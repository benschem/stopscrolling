# frozen_string_literal: true

# The decks a controller can deal from, and reading a dealt name out of the url
module Drawing
  extend ActiveSupport::Concern

  private

  def user_deck
    Deck.build_current_user_activities_deck(session, @activities)
  end

  def rogue_deck
    Deck.build_rogue_activities_deck(session, @activities)
  end

  def activity_from_url
    name = params[:activity_name]
    return unless drawable?(name)

    Activity.new(name: name)
  end

  # A name from neither deck is one somebody typed into the url themselves.
  def drawable?(name)
    name.present? && (in_user_list?(name) || in_seeded_list?(name))
  end

  def in_user_list?(name)
    @activities.map(&:name).include?(name)
  end

  def in_seeded_list?(name)
    ::SEEDED_ACTIVITIES.include?(name)
  end
end
