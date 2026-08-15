# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Session, type: :model do
  subject(:session) { create(:session) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe '#expired?' do
    context 'when the expiry has passed' do
      subject(:session) { create(:session, :expired) }

      it 'returns true' do
        expect(session.expired?).to be(true)
      end
    end

    context 'when the expiry is still ahead' do
      it 'returns false' do
        expect(session.expired?).to be(false)
      end
    end
  end

  describe '#renew!' do
    subject(:session) { create(:session, last_seen_at: 1.day.ago, expires_at: 1.day.from_now) }

    before { freeze_time }

    it 'pushes the expiry out to a full window' do
      expect { session.renew! }
        .to change { session.reload.expires_at }
        .to(Session::EXPIRES_IN.from_now)
    end

    it 'records that the session was just seen' do
      expect { session.renew! }
        .to change { session.reload.last_seen_at }
        .to(Time.current)
    end
  end
end
