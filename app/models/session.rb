# frozen_string_literal: true

# User session
class Session < ApplicationRecord
  belongs_to :user
end
