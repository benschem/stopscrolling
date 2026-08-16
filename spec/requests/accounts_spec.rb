# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/accounts', type: :request do
  describe 'GET /accounts/new' do
    context 'when they already have an account and are signed in' do
      before do
        sign_in(create(:account, :verified))
        get new_account_url
      end

      it 'sends them back to their list rather than showing the form', :aggregate_failures do
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq("You're already signed in.")
      end
    end
  end

  describe 'POST /create' do
    subject(:sign_up_for_an_account) { sign_up(email_address: taken_email) }

    context 'when they are already signed in' do
      let(:taken_email) { 'second@example.com' }
      let(:their_own_account) { create(:account, :verified) }

      before do
        sign_in(their_own_account)
        sign_up_for_an_account
      end

      it 'creates no second account for them' do
        expect(Account.where.not(id: their_own_account)).to be_empty
      end

      it 'sends them back to their list' do
        expect(response).to redirect_to(root_url)
      end
    end

    context 'with an email address that already has an account' do
      let(:taken_email) { 'taken@example.com' }

      before do
        create(:account, :verified, email_address: taken_email)
        sign_up_for_an_account
      end

      it 'offers to sign them in instead, with the address they typed' do
        expect(response.body).to include(new_session_path(email_address: taken_email))
      end
    end
  end
end
