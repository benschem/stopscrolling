# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CleanupUnverifiedUsersJob, type: :job do
  subject(:cleanup_unverified_users) { described_class.perform_now }

  describe '#perform' do
    let!(:stale_account) do
      create(
        :account,
        verified_at: nil,
        verification_sent_at: 8.days.ago,
        created_at: 8.days.ago
      )
    end

    let!(:fresh_unverified_account) do
      create(
        :account,
        verified_at: nil,
        verification_sent_at: 1.hour.ago,
        created_at: 1.hour.ago
      )
    end

    let!(:unverified_account) do
      create(
        :account,
        verified_at: nil,
        verification_sent_at: 2.days.ago,
        created_at: 2.days.ago
      )
    end

    let!(:verified_account) do
      create(
        :account,
        :verified,
        verification_sent_at: 8.days.ago,
        created_at: 8.days.ago
      )
    end

    let!(:guest) { create(:user, created_at: 8.days.ago) }

    before do
      cleanup_unverified_users
    end

    it 'never reaches a user who has no account' do
      expect(User.exists?(guest.id)).to be(true)
    end

    it 'destroys the user behind an account that was never verified in time' do
      expect(User.exists?(stale_account.user_id)).to be(false)
    end

    it 'does not destroy freshly signed up users' do
      expect(User.exists?(fresh_unverified_account.user_id)).to be(true)
    end

    it 'does not destroy users still inside the grace period' do
      expect(User.exists?(unverified_account.user_id)).to be(true)
    end

    it 'does not destroy verified users' do
      expect(User.exists?(verified_account.user_id)).to be(true)
    end
  end
end
