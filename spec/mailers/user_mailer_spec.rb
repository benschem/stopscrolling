# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user, verification_sent_at: nil) }

  describe '#verify_email_address' do
    subject(:mail) { described_class.verify_email_address(user) }

    context 'when sent' do
      before do
        mail.deliver_now
      end

      it 'records when the verification email was sent at' do
        expect(user.reload.verification_sent_at).not_to be_nil
      end
    end

    describe 'the email headers' do
      let(:email_subject) { 'Verify your email address' }
      let(:app_email_address) { 'no-reply@stopscroll.ing' }

      it 'includes the email subject' do
        expect(mail.subject).to eq(email_subject)
      end

      it "addressed to the user's email" do
        expect(mail.to).to eq([user.email_address])
      end

      it 'sent from the app email address' do
        expect(mail.from).to eq([app_email_address])
      end
    end

    describe 'the email body' do
      let(:html_body) { mail.html_part.body.decoded }
      let(:explanatory_text) { 'verify your email address' }
      let(:verification_link_regexp) { %r{http://example.com/verify_email_address\.[A-Za-z0-9\-_]+=*--[a-f0-9]+} }

      it 'includes explanatory text' do
        expect(html_body).to include(explanatory_text)
      end

      it 'includes a verification link' do
        expect(html_body).to match(verification_link_regexp)
      end
    end
  end
end
