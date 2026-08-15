# frozen_string_literal: true

# How someone signs in to the list they own. Kept apart from users so that owning a list does not
# require having signed up.
class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :email_address, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.datetime :verified_at
      t.datetime :verification_sent_at

      t.timestamps
    end
  end
end
