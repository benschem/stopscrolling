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

    it 'offers a way to sign up' do
      expect(response.body).to include('Sign up')
    end

    it 'offers no way to sign out' do
      expect(response.body).not_to include('Sign out')
    end
  end

  describe 'a first visit' do
    before { get activities_url }

    it 'starts them with an empty list' do
      expect(response.body).not_to include('<li id="activity_')
    end

    it 'leaves the list heading off until they have something to head' do
      expect(response.body).not_to include('Likes')
    end
  end

  describe 'POST /activities/pick' do
    before do
      post pick_activities_url
      follow_redirect!
    end

    it 'renders a successful response' do
      expect(response).to be_successful
    end
  end

  describe 'POST /activities/rogue' do
    before do
      post rogue_activities_url
      follow_redirect!
    end

    it 'renders a successful response' do
      expect(response).to be_successful
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
