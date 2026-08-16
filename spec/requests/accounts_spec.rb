# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/accounts', type: :request do
  describe 'POST /create' do
    subject(:sign_up_for_an_account) { sign_up(email_address: taken_email) }

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
