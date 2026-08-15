# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Signed out access', type: :request do
  describe 'GET /activities' do
    before { get activities_url }

    it 'renders the list' do
      expect(response).to be_successful
    end

    it 'offers a way to sign in' do
      expect(response.body).to include('Sign in')
    end
  end

  describe 'GET /activities/random' do
    before { get random_activities_url }

    it 'renders a successful response' do
      expect(response).to be_successful
    end
  end

  describe 'GET /activities/suggestion' do
    before { get suggestion_activities_url }

    it 'renders a successful response' do
      expect(response).to be_successful
    end
  end

  describe 'POST /activities' do
    subject(:request) { post activities_url, params: { activity: { name: 'Read a book' } } }

    it 'redirects to sign in' do
      request
      expect(response).to redirect_to(new_session_path)
    end

    it 'creates no activity' do
      expect { request }.not_to change(Activity, :count)
    end
  end

  describe 'browsing without a session' do
    it 'creates no user' do
      expect { get activities_url }.not_to change(User, :count)
    end

    it 'creates no session' do
      expect { get activities_url }.not_to change(Session, :count)
    end
  end
end
