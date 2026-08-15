# frozen_string_literal: true

# Someone who owns a list of activities, whether or not they have signed up
class User < ApplicationRecord
  has_one :account, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :activities, dependent: :destroy

  def signed_up?
    account.present?
  end
end
