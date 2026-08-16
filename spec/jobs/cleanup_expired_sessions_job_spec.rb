# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CleanupExpiredSessionsJob, type: :job do
  subject(:cleanup_expired_sessions) { described_class.perform_now }

  describe '#perform' do
    let!(:expired_session) { create(:session, :expired) }
    let!(:live_session) { create(:session) }

    before do
      cleanup_expired_sessions
    end

    it 'deletes a session nobody came back to renew' do
      expect(Session.exists?(expired_session.id)).to be(false)
    end

    it 'leaves a session that has not expired yet' do
      expect(Session.exists?(live_session.id)).to be(true)
    end

    it 'leaves the user behind an expired session' do
      expect(User.exists?(expired_session.user_id)).to be(true)
    end
  end
end
