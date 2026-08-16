# frozen_string_literal: true

# An Activity that a user could do instead of watching TV
class Activity < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validate :name_must_be_unique_within_the_list

  # Names are unique within a list and exist before the record is saved, unlike an id.
  def to_param
    name
  end

  private

  def name_must_be_unique_within_the_list
    return if name.blank? || user.nil?
    return unless name_taken_in_the_list?

    errors.add(:name, :taken)
  end

  def name_taken_in_the_list?
    return saved_list_has_the_name? if user.persisted?

    user.activities.any? { |other| !other.equal?(self) && other.name == name }
  end

  def saved_list_has_the_name?
    user.activities.where(name: name).where.not(id: id).exists?
  end
end
