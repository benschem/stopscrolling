# frozen_string_literal: true

require 'rails_helper'

# A guest is a user with no account: someone who added an activity without signing up.
RSpec.describe 'Guests', type: :request do
  def add_as_a_visitor(name)
    get activities_url
    post activities_url, params: { activity: { name: name } }
  end

  context 'when a visitor adds their first activity' do
    subject(:add_activity) { post activities_url, params: { activity: { name: 'Go for a walk' } } }

    let(:guest) { User.sole }
    let(:suggested_names) { suggestions }

    before do
      get activities_url
      suggested_names # pin them, before adding clears the session
      add_activity
    end

    it 'takes them back to the list rather than to sign in' do
      expect(response).to redirect_to(activities_url)
    end

    it 'leaves them without an account' do
      expect(guest).not_to be_signed_up
    end

    it 'saves the whole visible list, not just what they typed' do
      expect(guest.activities.pluck(:name)).to match_array(suggested_names + ['Go for a walk'])
    end

    it 'starts a session so they are recognised next time' do
      expect(guest.sessions.count).to eq(1)
    end

    it 'stops suggesting, now that the list is theirs' do
      expect(suggestions).to be_nil
    end

    context 'when they look at the list afterwards' do
      before { get activities_url }

      it 'heads it as their own' do
        expect(response.body).to include('Things you like doing')
      end
    end
  end

  context 'when a visitor adds something they were already shown' do
    subject(:add_a_suggestion) { post activities_url, params: { activity: { name: suggestions.first } } }

    before do
      get activities_url
      add_a_suggestion
    end

    it 'refuses it with a validation error', :aggregate_failures do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('has already been taken')
    end

    it 'persists nothing' do
      expect(User.count).to be_zero
    end
  end

  context 'when a guest comes back within the session lifetime' do
    subject(:come_back) { get activities_url }

    before do
      add_as_a_visitor('Go for a walk')
      travel(Session::EXPIRES_IN - 1.day)
      come_back
    end

    it 'shows them the list they saved' do
      expect(response.body).to include('Go for a walk')
    end

    it 'suggests nothing over the top of it' do
      expect(suggestions).to be_nil
    end
  end

  context 'when a guest comes back after the session has expired' do
    subject(:come_back) { get activities_url }

    before do
      add_as_a_visitor('Go for a walk')
      travel(Session::EXPIRES_IN + 1.day)
      come_back
    end

    it 'treats them as a visitor again' do
      expect(suggestions.size).to eq(DemoActivityList::SIZE)
    end

    it 'no longer shows the list they saved' do
      expect(response.body).not_to include('Go for a walk')
    end

    it 'leaves the abandoned user for the sweep rather than destroying it' do
      expect(User.count).to eq(1)
    end
  end

  context 'when a guest adds another activity' do
    subject(:add_another) { post activities_url, params: { activity: { name: 'Read a book' } } }

    let(:guest) { User.sole }

    before do
      add_as_a_visitor('Go for a walk')
      add_another
    end

    it 'adds it to the list they already have' do
      expect(guest.activities.pluck(:name)).to include('Go for a walk', 'Read a book')
    end
  end

  context 'when a guest deletes an activity' do
    subject(:delete_activity) { delete activity_url('Read a book') }

    let(:guest) { User.sole }

    before do
      add_as_a_visitor('Go for a walk')
      post activities_url, params: { activity: { name: 'Read a book' } }
      delete_activity
    end

    it 'removes it from their list' do
      expect(guest.activities.pluck(:name)).not_to include('Read a book')
    end

    it 'leaves the rest alone' do
      expect(guest.activities.pluck(:name)).to include('Go for a walk')
    end
  end

  context 'when a guest deletes everything they saved' do
    let(:guest) { User.sole }

    before do
      add_as_a_visitor('Go for a walk')
      guest.activities.each { |activity| delete activity_url(activity) }
      get activities_url
    end

    it 'leaves them with an empty list' do
      expect(guest.activities.reload).to be_empty
    end

    it 'suggests nothing over the top of it' do
      expect(suggestions).to be_nil
    end

    it 'keeps the user they became' do
      expect(User.count).to eq(1)
    end
  end
end
