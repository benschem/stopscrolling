# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Demo activity list', type: :request do
  describe 'GET /activities' do
    context 'when signed out' do
      before { get activities_url }

      it 'suggests a list of activities' do
        expect(suggestions.size).to eq(DemoActivityList::SIZE)
      end

      it 'shows each of them, addressed by name' do
        expect(response.body).to include(*suggestions.map { |name| activity_path(name) })
      end

      it 'heads the list as suggestions rather than as their own' do
        expect(response.body).to include('Things you could be doing')
      end
    end

    context 'when signed in' do
      before do
        sign_in(create(:account, :verified))
        get activities_url
      end

      it 'suggests nothing' do
        expect(suggestions).to be_nil
      end

      it 'shows the empty state instead' do
        expect(response.body).to include('Nothing here yet')
      end

      it 'heads the list as their own' do
        expect(response.body).to include('Things you like doing')
      end
    end
  end

  context 'when browsing as a visitor' do
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

  context 'when a visitor dismisses a suggestion' do
    subject(:dismiss) { delete activity_url(dismissed_name) }

    let(:dismissed_name) { suggestions.first }

    before do
      get activities_url
      dismissed_name # pin it, before dismissing changes what "first" means
    end

    it 'saves nothing' do
      expect { dismiss }.not_to change(Activity, :count)
    end

    context 'when it has been dismissed' do
      before { dismiss }

      it 'takes them back to the list rather than to sign in' do
        expect(response).to redirect_to(root_url)
      end

      it 'drops it from the suggestions' do
        expect(suggestions).not_to include(dismissed_name)
      end

      it 'stops showing it' do
        get activities_url
        expect(response.body).not_to include(dismissed_name)
      end
    end
  end

  context 'when a visitor dismisses every suggestion' do
    before do
      get activities_url
      suggestions.each { |name| delete activity_url(name) }
    end

    it 'suggests a fresh set on the next request' do
      get activities_url
      expect(suggestions.size).to eq(DemoActivityList::SIZE)
    end

    it 'saves nothing' do
      expect(Activity.count).to be_zero
    end
  end

  context 'when a visitor comes back in a new browser session' do
    before do
      get activities_url
      reset!
      get activities_url
    end

    it 'suggests a fresh set' do
      expect(suggestions.size).to eq(DemoActivityList::SIZE)
    end

    it 'saves nothing' do
      expect(Activity.count).to be_zero
    end
  end

  context 'when a visitor signs up without adding anything' do
    let(:email_address) { 'visitor@example.com' }
    let(:new_account) { Account.find_by(email_address: email_address) }
    let(:names_before_signing_up) { suggestions }

    before do
      get activities_url
      names_before_signing_up
      sign_up(email_address: email_address)
    end

    it 'keeps the suggestions as the list of the account they just made' do
      expect(new_account.user.activities.pluck(:name)).to match_array(names_before_signing_up)
    end
  end

  context 'when they sign out after signing up' do
    before do
      get activities_url
      sign_up(email_address: 'visitor@example.com')
      delete session_url
      get activities_url
    end

    it 'suggests a fresh set rather than the list they took with them' do
      expect(suggestions).not_to match_array(Activity.pluck(:name))
    end
  end

  context 'when they sign in after the session expired' do
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
      expect(suggestions).to be_nil
    end

    it 'shows their own list' do
      expect(response.body).to include('Go for a walk')
    end

    it 'leaves no stray user behind' do
      expect(User.count).to eq(1)
    end
  end
end
