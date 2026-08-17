# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#headline_for' do
    subject(:headline) { helper.headline_for(activity) }

    let(:activity) { build_stubbed(:activity, name: 'Watch Dr. Who') }

    it 'sets the activity apart from the phrase leading up to it' do
      expect(headline).to include('<strong>watch dr. who</strong>')
    end

    context 'when nothing has been drawn' do
      let(:activity) { nil }

      it 'tells them to get off their phone instead' do
        expect(headline).to include('Get off your phone')
      end
    end
  end

  describe '#headline_size' do
    it 'sets a short headline at the biggest size' do
      expect(helper.headline_size('Go and do yoga.')).to eq('short')
    end

    it 'shrinks one too long to fit the plate at that size' do
      expect(helper.headline_size('Put the phone down and go and do some vehicle restoration.')).to eq('long')
    end
  end

  describe '#activity_dom_id' do
    subject(:dom_id) { helper.activity_dom_id(activity) }

    let(:activity) { build(:activity, name: 'Watch Dr. Who') }

    it { is_expected.to eq('activity_watch-dr-who') }
  end
end
