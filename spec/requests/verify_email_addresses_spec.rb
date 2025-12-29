# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Email address verification', type: :request do
  describe 'GET /verify_email_address' do
    subject(:request) { get verify_email_address_path, params: { token: token } }

    context 'when the user is already verified' do
      let(:user) { create(:user, :verified) }
      let(:token) { user.email_address_verification_token }

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

    context 'when the user is unverified and can be verified' do
      let(:user) { create(:user) }
      let(:token) { user.email_address_verification_token }

      before do
        request
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash notice' do
        expect(flash[:notice]).to eq('Email address verified successfully.')
      end

      it 'marks the user as verified' do
        expect(user.reload).to be_verified
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

    context 'when the token does not match any user' do
      let(:token) { 'this-will-not-be-checked' }

      before do
        allow(User).to receive(:find_by).and_return(nil)
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
