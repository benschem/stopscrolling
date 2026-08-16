# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#activity_dom_id' do
    subject(:dom_id) { helper.activity_dom_id(activity) }

    let(:activity) { build(:activity, name: 'Watch Dr. Who') }

    it { is_expected.to eq('activity_watch-dr-who') }
  end
end
