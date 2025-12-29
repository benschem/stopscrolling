# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { create(:user, password: password) }

  let(:password) { 'secret123' }

  describe 'password' do
    it { is_expected.to have_secure_password }

    context 'without a password' do
      let(:user) { build(:user, password: nil) }

      it 'is invalid on create' do
        expect(user).not_to be_valid
      end
    end

    context 'with the correct password' do
      let(:correct_password) { password }

      it 'authenticates with the correct password' do
        expect(user.authenticate(correct_password)).to eq(user)
      end
    end

    context 'with an incorrect password' do
      let(:incorrect_password) { 'wrong' }

      it 'does not authenticates with an incorrect password' do
        expect(user.authenticate(incorrect_password)).to be_falsey
      end
    end
  end

  describe 'associations' do
    it do
      expect(user).to have_many(:activities).dependent(:destroy)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email_address) }

    it do
      expect(user)
        .to validate_uniqueness_of(:email_address)
        .case_insensitive
    end

    it do
      expect(user)
        .to allow_value('user@example.com')
        .for(:email_address)
    end

    it do # rubocop:disable RSpec/ExampleLength
      expect(user).not_to allow_value(
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
        user.update(email_address: '  EXAMPLE@Email.COM ')
        user.validate
      end

      it 'downcases and strips the email address' do
        expect(user.email_address).to eq('example@email.com')
      end
    end
  end

  describe '#verify!' do
    before do
      user.verify!
    end

    it 'records the time the user verified their email address' do
      expect(user.verified_at).to be_truthy
    end
  end

  describe '#verified?' do
    context 'when user has verified their email address' do
      before do
        user.update!(verified_at: 1.hour.ago.to_date)
      end

      it 'returns true' do
        expect(user.verified?).to be(true)
      end
    end

    context 'when user has not verified their email address' do
      before do
        user.update!(verified_at: nil)
      end

      it 'returns false' do
        expect(user.verified?).to be(false)
      end
    end
  end

  describe '#unverified?' do
    context 'when user has verified their email address' do
      before do
        user.update!(verified_at: 1.hour.ago)
      end

      it 'returns false' do
        expect(user.unverified?).to be(false)
      end
    end

    context 'when user has not verified their email address' do
      before do
        user.update!(verified_at: nil)
      end

      it 'returns true' do
        expect(user.unverified?).to be(true)
      end
    end
  end

  describe '#verification_expired?' do
    let(:expired_timestamp) do
      EmailAddressVerification::TOKEN_EXPIRES_IN.ago.to_date + 10.minutes
    end

    before do
      user.update!(verified_at: expired_timestamp)
    end

    context 'when verification link has expired' do
      before do
        user.update!(verified_at: nil)
      end

      it 'returns true' do
        expect(user.unverified?).to be(true)
      end
    end

    context 'when user is verified' do
      before do
        user.update!(verified_at: Date.yesterday)
      end

      it 'returns false' do
        expect(user.unverified?).to be(false)
      end
    end
  end
end
