# frozen_string_literal: true

# Create Sessions table. Sessions have a user, IP address and user-agent.
class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.datetime :last_seen_at
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
