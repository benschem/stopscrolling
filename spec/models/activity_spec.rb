# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  subject(:activity) { build(:activity) }

  let(:name) { 'Read a book' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    context 'when the user already has an activity with that name' do
      subject(:duplicate) { build(:activity, name: name, user: existing.user) }

      let!(:existing) { create(:activity, name: name) }

      it { is_expected.not_to be_valid }

      it 'lets the existing activity keep its own name' do
        expect(existing).to be_valid
      end
    end

    context 'when another user has an activity with that name' do
      subject(:activity) { build(:activity, name: name) }

      before { create(:activity, name: name) }

      it { is_expected.to be_valid }
    end

    context 'when the list has not been saved yet' do
      subject(:duplicate) { user.activities.build(name: name) }

      let(:user) { build(:user) }

      before do
        user.activities.build(name: name)
        duplicate.validate
      end

      it 'reports a repeated name as taken' do
        expect(duplicate.errors).to be_of_kind(:name, :taken)
      end

      it 'accepts a name that is not in the list yet' do
        expect(user.activities.build(name: 'Go for a walk')).to be_valid
      end
    end
  end
end
