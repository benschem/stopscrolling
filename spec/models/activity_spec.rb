# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  subject(:activity) { build(:activity) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }
  end

  describe 'name uniqueness' do
    let(:name) { 'Read a book' }

    before { create(:activity, name: name) }

    it 'lets a different user like the same activity' do
      expect(build(:activity, name: name)).to be_valid
    end
  end
end
