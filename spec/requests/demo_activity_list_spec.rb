# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Demo activity list', type: :request do
  let(:suggested_names) { session[DemoActivityList::KEY] }

  describe 'GET /activities as a visitor' do
    before { get activities_url }

    it 'suggests five activities' do
      expect(suggested_names.size).to eq(5)
    end

    it 'shows each of them, addressed by name' do
      expect(response.body).to include(*suggested_names.map { |name| activity_path(name) })
    end

    it 'heads the list as suggestions rather than as their own' do
      expect(response.body).to include('Things you could be doing')
    end
  end

  describe 'browsing as a visitor' do
    it 'saves nothing when looking at the list' do
      expect { get activities_url }.not_to change(Activity, :count)
    end

    it 'saves nothing when asking for something from the list' do
      expect { get random_activities_url }.not_to change(Activity, :count)
    end

    it 'saves nothing when asking for a suggestion' do
      expect { get suggestion_activities_url }.not_to change(Activity, :count)
    end
  end

  describe 'coming back in a new browser session' do
    before do
      get activities_url
      reset!
      get activities_url
    end

    it 'suggests a fresh five' do
      expect(suggested_names.size).to eq(5)
    end

    it 'still has nothing saved' do
      expect(Activity.count).to be_zero
    end
  end

  describe 'signing up without adding anything' do
    let(:email_address) { 'visitor@example.com' }
    let(:new_account) { Account.find_by(email_address: email_address) }

    before do
      get activities_url
      suggested_names # read while the suggestions are still in the session
      sign_up(email_address: email_address)
    end

    it 'keeps the suggestions as the list of the account they just made' do
      expect(new_account.user.activities.pluck(:name)).to match_array(suggested_names)
    end
  end

  describe 'signing out after signing up' do
    before do
      get activities_url
      sign_up(email_address: 'visitor@example.com')
      delete session_url
      get activities_url
    end

    it 'suggests a fresh five rather than the list they took with them' do
      expect(suggested_names).not_to match_array(Activity.pluck(:name))
    end
  end

  describe 'signing in after the session expired' do
    let(:account) { create(:account, :verified) }

    before do
      create(:activity, user: account.user, name: 'Go for a walk')
      sign_in(account)
      travel(Session::EXPIRES_IN + 1.day)
      get activities_url # expired: they are a visitor again, and get suggestions
      sign_in(account)
      get activities_url
    end

    it 'discards the suggestions they were shown while signed out' do
      expect(suggested_names).to be_nil
    end

    it 'shows their own list' do
      expect(response.body).to include('Go for a walk')
    end

    it 'leaves no stray user behind' do
      expect(User.count).to eq(1)
    end
  end

  describe 'GET /activities when signed in' do
    before do
      sign_in(create(:account, :verified))
      get activities_url
    end

    it 'suggests nothing' do
      expect(suggested_names).to be_nil
    end

    it 'shows the empty state instead' do
      expect(response.body).to include('Nothing here yet')
    end

    it 'heads the list as their own' do
      expect(response.body).to include('Things you like doing')
    end
  end
end
