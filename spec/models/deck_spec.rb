# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck, type: :model do
  subject(:deck) { described_class.build_current_user_activities_deck(session, activities) }

  let(:session) { {} }
  let(:cards) { %w[Yoga Bingo Cycling Pottery] }
  let(:activities) { cards.map { |name| build_stubbed(:activity, name: name) } }

  describe '#draw' do
    it 'turns over one of the cards it was dealt' do
      expect(cards).to include(deck.draw)
    end

    context 'with no cards at all' do
      let(:cards) { [] }

      it 'draws nothing' do
        expect(deck.draw).to be_nil
      end
    end

    context 'with only one card' do
      let(:cards) { ['Yoga'] }

      it 'keeps turning over the one there is' do
        expect(deck.draw).to eq('Yoga')
      end
    end

    context 'when drawn as many times as there are cards' do
      let(:round) { Array.new(cards.size) { deck.draw } }

      it 'turns each card over once rather than repeating' do
        expect(round).to match_array(cards)
      end
    end

    context 'when the deck has run out' do
      let!(:card_that_closed_the_round) { Array.new(cards.size) { deck.draw }.last }

      it 'shuffles the discard pile back in rather than drawing nothing' do
        expect(cards).to include(deck.draw)
      end

      it 'opens the new round with a different card' do
        expect(deck.draw).not_to eq(card_that_closed_the_round)
      end
    end

    context 'when a card is added part way through a round' do
      let(:new_card) { build_stubbed(:activity, name: 'Bread making') }
      let(:deck_with_the_new_card) do
        described_class.build_current_user_activities_deck(session, [*activities, new_card])
      end

      before { cards.size.times { deck.draw } }

      it 'turns the new one over before starting the deck again' do
        expect(deck_with_the_new_card.draw).to eq('Bread making')
      end
    end
  end

  describe '.build_rogue_activities_deck' do
    subject(:deck) { described_class.build_rogue_activities_deck(session, activities) }

    let(:cards) { ['Yoga'] }

    before { stub_const('SEEDED_ACTIVITIES', ['Yoga', 'Bread making']) }

    it 'deals only what is not already on their list' do
      expect(deck.draw).to eq('Bread making')
    end
  end

  describe '.clear' do
    before do
      stub_const('SEEDED_ACTIVITIES', ['Bread making'])
      described_class.build_current_user_activities_deck(session, activities).draw
      described_class.build_rogue_activities_deck(session, activities).draw
      described_class.clear(session)
    end

    it 'forgets what has been dealt from either deck' do
      expect(session).to be_empty
    end
  end
end
