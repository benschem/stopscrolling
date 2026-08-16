# frozen_string_literal: true

# An Activity that a user could do instead of watching TV
class Activity < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }

  # Names are unique within a list and exist before the record is saved, unlike an id.
  def to_param
    name
  end
end
