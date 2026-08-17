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

    before do
      get activities_url
      add_activity
    end

    it 'takes them back to the list rather than to sign in' do
      expect(response).to redirect_to(root_url)
    end

    it 'leaves them without an account' do
      expect(guest).not_to be_signed_up
    end

    it 'saves what they typed and nothing else' do
      expect(guest.activities.pluck(:name)).to eq(['Go for a walk'])
    end

    it 'starts a session so they are recognised next time' do
      expect(guest.sessions.count).to eq(1)
    end
  end

  context 'when a visitor adds the same thing twice' do
    let(:rejected_row_id) { 'id="activity_go-for-a-walk"' }

    before do
      add_as_a_visitor('Go for a walk')
      post activities_url, params: { activity: { name: 'Go for a walk' } }
    end

    it 'refuses it with a validation error', :aggregate_failures do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('has already been taken')
    end

    it 'saves it once' do
      expect(User.sole.activities.pluck(:name)).to eq(['Go for a walk'])
    end

    it 'leaves the rejected activity out of the list' do
      expect(response.body.scan(rejected_row_id).count).to eq(1)
    end
  end

  context 'when a visitor goes rogue' do
    before do
      stub_const('SEEDED_ACTIVITIES', ['Bread making'])
      post rogue_activities_url
      follow_redirect!
    end

    it 'offers them something' do
      expect(response.body).to include('bread making')
    end

    it 'saves nothing' do
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
  end

  context 'when a guest comes back after the session has expired' do
    subject(:come_back) { get activities_url }

    before do
      add_as_a_visitor('Go for a walk')
      travel(Session::EXPIRES_IN + 1.day)
      come_back
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

    it 'keeps the user they became' do
      expect(User.count).to eq(1)
    end
  end

  context 'when a guest signs up' do
    subject(:sign_up_for_an_account) { sign_up(email_address: 'guest@example.com') }

    let(:new_account) { Account.sole }
    let(:guest_before_signing_up) { User.sole }
    let(:session_before_signing_up) { Session.sole }
    let(:list_before_signing_up) { guest_before_signing_up.activities.pluck(:name) }

    before do
      add_as_a_visitor('Go for a walk')
      list_before_signing_up # pin what they had, before an account is attached to it
      session_before_signing_up
      sign_up_for_an_account
    end

    it 'attaches the account to the user row they already have' do
      expect(new_account.user).to eq(guest_before_signing_up)
    end

    it 'leaves their list where it was' do
      expect(new_account.user.activities.pluck(:name)).to match_array(list_before_signing_up)
    end

    it 'rotates their session rather than adding another', :aggregate_failures do
      expect(Session.count).to eq(1)
      expect(Session.sole).not_to eq(session_before_signing_up)
    end
  end

  context 'when a visitor signs up without adding anything' do
    let(:email_address) { 'visitor@example.com' }
    let(:new_account) { Account.find_by(email_address: email_address) }

    before do
      get activities_url
      sign_up(email_address: email_address)
    end

    it 'starts them off with an empty list' do
      expect(new_account.user.activities).to be_empty
    end
  end

  context 'when a guest signs up with an email that is taken' do
    subject(:sign_up_for_an_account) { sign_up(email_address: taken_email) }

    let(:taken_email) { 'taken@example.com' }
    let(:guest) { User.where.missing(:account).sole }
    let(:list_before_signing_up) { guest.activities.pluck(:name) }

    before do
      create(:account, :verified, email_address: taken_email)
      add_as_a_visitor('Go for a walk')
      list_before_signing_up
      sign_up_for_an_account
    end

    it 'refuses it with a validation error', :aggregate_failures do
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('has already been taken')
    end

    it 'leaves their list untouched' do
      expect(guest.activities.reload.pluck(:name)).to match_array(list_before_signing_up)
    end
  end

  context 'when a guest signs in to an existing account' do
    subject(:sign_in_to_the_account) { sign_in(account) }

    let(:account) { create(:account, :verified) }
    let(:guest) { User.where.missing(:account).sole }

    before do
      create(:activity, user: account.user, name: 'Play the piano')
      add_as_a_visitor('Go for a walk')
      sign_in_to_the_account
      get activities_url
    end

    it "shows them the account's list" do
      expect(response.body).to include('Play the piano')
    end

    it 'stops showing what they had as a guest' do
      expect(response.body).not_to include('Go for a walk')
    end

    it 'leaves the abandoned guest for the sweep rather than destroying it' do
      expect(guest.activities.pluck(:name)).to include('Go for a walk')
    end
  end
end
