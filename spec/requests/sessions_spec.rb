# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:account) { create(:account, :verified) }

  describe 'POST /session' do
    before { sign_in(account) }

    it 'replaces the existing session rather than adding another' do
      expect { sign_in(account) }.not_to change(Session, :count)
    end
  end

  describe 'DELETE /session' do
    before { sign_in(account) }

    it 'destroys the session' do
      expect { delete session_url }.to change(Session, :count).by(-1)
    end

    it 'does not start a new one on the next request' do
      delete session_url

      expect { get activities_url }.not_to change(Session, :count)
    end
  end
end
