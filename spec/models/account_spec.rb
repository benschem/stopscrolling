# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  subject(:account) { create(:account, password: password) }

  let(:password) { 'secret123' }

  describe 'password' do
    it { is_expected.to have_secure_password }

    context 'without a password' do
      let(:account) { build(:account, password: nil) }

      it 'is invalid on create' do
        expect(account).not_to be_valid
      end
    end

    context 'with the correct password' do
      let(:correct_password) { password }

      it 'authenticates with the correct password' do
        expect(account.authenticate(correct_password)).to eq(account)
      end
    end

    context 'with an incorrect password' do
      let(:incorrect_password) { 'wrong' }

      it 'does not authenticates with an incorrect password' do
        expect(account.authenticate(incorrect_password)).to be_falsey
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email_address) }

    it do
      expect(account)
        .to validate_uniqueness_of(:email_address)
        .case_insensitive
    end

    it do
      expect(account)
        .to allow_value('user@example.com')
        .for(:email_address)
    end

    it do # rubocop:disable RSpec/ExampleLength
      expect(account).not_to allow_value(
        'user',
        'user@',
        '@example.com',
        'user@.com'
      ).for(:email_address)
    end
  end

  describe 'normalizations' do
    describe ':email_address' do
      before do
        account.update(email_address: '  EXAMPLE@Email.COM ')
        account.validate
      end

      it 'downcases and strips the email address' do
        expect(account.email_address).to eq('example@email.com')
      end
    end
  end

  describe '#verify!' do
    before do
      account.verify!
    end

    it 'records the time the email address was verified' do
      expect(account.verified_at).to be_truthy
    end
  end

  describe '#verified?' do
    context 'when the email address has been verified' do
      before do
        account.update!(verified_at: 1.hour.ago.to_date)
      end

      it 'returns true' do
        expect(account.verified?).to be(true)
      end
    end

    context 'when the email address has not been verified' do
      before do
        account.update!(verified_at: nil)
      end

      it 'returns false' do
        expect(account.verified?).to be(false)
      end
    end
  end

  describe '#unverified?' do
    context 'when the email address has been verified' do
      before do
        account.update!(verified_at: 1.hour.ago)
      end

      it 'returns false' do
        expect(account.unverified?).to be(false)
      end
    end

    context 'when the email address has not been verified' do
      before do
        account.update!(verified_at: nil)
      end

      it 'returns true' do
        expect(account.unverified?).to be(true)
      end
    end
  end

  describe '#verification_expired?' do
    context 'when the verification link has expired' do
      before do
        account.update!(verification_sent_at: (EmailAddressVerification::TOKEN_EXPIRES_IN + 1.hour).ago)
      end

      it 'returns true' do
        expect(account.verification_expired?).to be(true)
      end
    end

    context 'when the verification link is still valid' do
      before do
        account.update!(verification_sent_at: 1.hour.ago)
      end

      it 'returns false' do
        expect(account.verification_expired?).to be(false)
      end
    end
  end
end
