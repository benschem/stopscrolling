# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CleanupExpiredSessionsJob, type: :job do
  subject(:cleanup_expired_sessions) { described_class.perform_now }

  describe '#perform' do
    let!(:expired_sessions) { create_list(:session, 2, :expired) }
    let!(:live_session) { create(:session) }

    before do
      allow(Rails.logger).to receive(:info)
      cleanup_expired_sessions
    end

    it 'deletes a session nobody came back to renew' do
      expect(Session.where(id: expired_sessions)).to be_empty
    end

    it 'leaves a session that has not expired yet' do
      expect(Session.exists?(live_session.id)).to be(true)
    end

    it 'leaves the user behind an expired session' do
      expect(User.exists?(expired_sessions.first.user_id)).to be(true)
    end

    it 'logs how many sessions it took' do
      expect(Rails.logger).to have_received(:info)
        .with("CleanupExpiredSessionsJob deleted #{expired_sessions.count} expired sessions")
    end
  end
end
