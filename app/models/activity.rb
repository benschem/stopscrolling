# frozen_string_literal: true

# An Activity that a user could do instead of watching TV
class Activity < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
