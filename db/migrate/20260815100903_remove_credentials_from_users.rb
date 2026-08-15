# frozen_string_literal: true

# Credentials now live on accounts
class RemoveCredentialsFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, :email_address, unique: true
    remove_column :users, :email_address, :string, null: false
    remove_column :users, :password_digest, :string, null: false
    remove_column :users, :verified_at, :datetime
    remove_column :users, :verification_sent_at, :datetime
  end
end
