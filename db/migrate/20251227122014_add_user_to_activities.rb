# frozen_string_literal: true

# A user has many activities, activities belong to a user
class AddUserToActivities < ActiveRecord::Migration[8.0]
  def change
    add_reference :activities, :user, foreign_key: true
  end
end
