# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'associations' do
    it { is_expected.to have_one(:account).dependent(:destroy) }
    it { is_expected.to have_many(:activities).dependent(:destroy) }
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end

  describe '#activities' do
    subject(:user) { create(:user) }

    before do
      create(:activity, user: user, name: 'Zebra spotting')
      create(:activity, user: user, name: 'Amateur radio')
      create(:activity, user: user, name: 'Making bread')
    end

    it 'keeps them in the order they were added' do
      expect(user.activities.map(&:name)).to eq(['Zebra spotting', 'Amateur radio', 'Making bread'])
    end
  end

  describe '#signed_up?' do
    context 'when the user has an account' do
      subject(:user) { create(:user, :signed_up) }

      it 'returns true' do
        expect(user.signed_up?).to be(true)
      end
    end

    context 'when the user has no account' do
      subject(:user) { create(:user) }

      it 'returns false' do
        expect(user.signed_up?).to be(false)
      end
    end
  end
end
