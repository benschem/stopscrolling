# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Email address verification', type: :request do
  describe 'GET /verify_email_address' do
    subject(:request) { get verify_email_address_path(token) }

    context 'when the account is already verified' do
      let(:account) { create(:account, :verified) }
      let(:token) { account.email_address_verification_token }

      before do
        request
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash notice' do
        expect(flash[:notice]).to eq('Email address is already verified.')
      end
    end

    context 'when the account is unverified and can be verified' do
      let(:account) { create(:account) }
      let(:token) { account.email_address_verification_token }

      before do
        request
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash notice' do
        expect(flash[:notice]).to eq('Email address verified successfully.')
      end

      it 'marks the account as verified' do
        expect(account.reload).to be_verified
      end
    end

    context 'when the token is invalid' do
      let(:token) { 'invalid-token' }

      before do
        request
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash alert' do
        expect(flash[:alert]).to eq('Something went wrong. Please try again.')
      end
    end

    context 'when the token does not match any account' do
      let(:token) { 'this-will-not-be-checked' }

      before do
        allow(Account).to receive(:find_by_token_for).and_return(nil)
        request
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash alert' do
        expect(flash[:alert]).to eq('Something went wrong. Please try again.')
      end
    end
  end
end
