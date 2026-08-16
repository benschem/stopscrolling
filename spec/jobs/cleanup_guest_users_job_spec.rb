# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CleanupGuestUsersJob, type: :job do
  subject(:cleanup_guest_users) { described_class.perform_now }

  describe '#perform' do
    let!(:abandoned_guests) { create_list(:user, 2, created_at: (Session::EXPIRES_IN + 1.day).ago) }
    let!(:fresh_guest) { create(:user, created_at: 5.seconds.ago) }
    let!(:guest_with_a_session) do
      create(:user, created_at: (Session::EXPIRES_IN + 1.day).ago).tap do |user|
        create(:session, user:)
      end
    end
    let!(:old_signed_up_user) { create(:user, :signed_up, created_at: 1.year.ago) }

    before do
      create(:activity, user: abandoned_guests.first)
      allow(Rails.logger).to receive(:info)
      cleanup_guest_users
    end

    it 'destroys a guest with no account, no session, and nothing to come back to' do
      expect(User.where(id: abandoned_guests)).to be_empty
    end

    it 'destroys the abandoned list along with the guest' do
      expect(Activity.exists?(user_id: abandoned_guests.first.id)).to be(false)
    end

    it 'leaves a guest saved seconds ago whose session has not started yet' do
      expect(User.exists?(fresh_guest.id)).to be(true)
    end

    it 'leaves a guest who can still be identified by a session' do
      expect(User.exists?(guest_with_a_session.id)).to be(true)
    end

    it 'leaves a signed up user however old' do
      expect(User.exists?(old_signed_up_user.id)).to be(true)
    end

    it 'logs how many guests it took' do
      expect(Rails.logger).to have_received(:info)
        .with("CleanupGuestUsersJob deleted #{abandoned_guests.count} abandoned guests")
    end
  end
end
