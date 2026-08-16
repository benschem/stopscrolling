# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:account) { create(:account, :verified) }

  describe 'GET /session/new' do
    context 'when they are already signed in' do
      before do
        sign_in(account)
        get new_session_url
      end

      it 'sends them back to their list rather than showing the form', :aggregate_failures do
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq("You're already signed in.")
      end
    end
  end

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

    it 'leaves the visitor signed out' do
      delete session_url
      get activities_url

      expect(response.body).to include('Sign in')
    end
  end
end
