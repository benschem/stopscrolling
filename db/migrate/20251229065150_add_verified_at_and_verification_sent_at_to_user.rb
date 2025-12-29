# frozen_string_literal: true

# Verify user's email address on sign up
class AddVerifiedAtAndVerificationSentAtToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :verified_at, :datetime
    add_column :users, :verification_sent_at, :datetime
  end
end
