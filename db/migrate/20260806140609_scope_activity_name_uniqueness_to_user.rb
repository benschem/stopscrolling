# frozen_string_literal: true

# Activity names only need to be unique within a single user's list. The original index made them
# unique across the whole table, so two users could never both like the same thing.
class ScopeActivityNameUniquenessToUser < ActiveRecord::Migration[8.0]
  def change
    remove_index :activities, :name, unique: true
    add_index :activities, %i[user_id name], unique: true
  end
end
