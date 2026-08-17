# frozen_string_literal: true

# A deck of activity names dealt one card at a time.
#
# - Every card is turned over once before any comes up again
# - Every card turned over goes to the discard pile
# - Only what is left in the deck can be drawn
# - When the deck runs out the discard pile is shuffled back in
# - Discard pile lives in the session, so a round lasts as long as the tab does
#
class Deck
  USER_LIST_KEY = :current_user_activities_deck
  ROGUE_LIST_KEY = :rogue_activities_deck

  def self.build_current_user_activities_deck(session, activities)
    cards = activities.map(&:name)
    new(session, USER_LIST_KEY, cards)
  end

  def self.build_rogue_activities_deck(session, activities)
    cards = SEEDED_ACTIVITIES - activities.map(&:name)
    new(session, ROGUE_LIST_KEY, cards)
  end

  # A round belongs to whoever was signed in when it started
  # Signing in or out clears the table
  def self.clear(session)
    session.delete(USER_LIST_KEY)
    session.delete(ROGUE_LIST_KEY)
  end

  def initialize(session, key, cards)
    @session = session
    @key = key
    @cards = cards
    @discard_pile = session.fetch(key, []) & cards # Remove activities deleted during a round
  end

  def draw
    return if cards.empty?

    discarded = discard_pile
    face_down = cards - discarded

    if face_down.empty?
      face_down = fresh_deck_after(discarded.last)
      discarded = []
    end

    drawn = face_down.sample
    discard([*discarded, drawn])
    drawn
  end

  private

  attr_reader :session, :key, :cards, :discard_pile

  # Every card back in the deck, bar the one just turned over. Holding that single card out
  # of the new round's first draw is what stops the last card of one round and the first of
  # the next being the same, which reads as stuck rather than shuffled.
  def fresh_deck_after(last_drawn)
    fresh_deck = (cards - [last_drawn])
    fresh_deck.presence || cards
  end

  def discard(pile)
    @discard_pile = pile
    session[key] = pile
  end
end
