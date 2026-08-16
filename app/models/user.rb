# frozen_string_literal: true

# Someone who owns a list of activities, whether or not they have signed up
class User < ApplicationRecord
  has_one :account, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :activities, -> { order(:created_at, :id) }, dependent: :destroy, inverse_of: :user

  # Abandoned because there's no user to sign in as and no session with the browser.
  # The age check spares a guest saved moments ago whose session has not started yet.
  scope :abandoned_guests, lambda {
    where.missing(:account, :sessions).where(created_at: ...Session::EXPIRES_IN.ago)
  }

  def signed_up?
    account.present?
  end
end
