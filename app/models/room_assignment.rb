# frozen_string_literal: true

# Model to represent room assignments
#
# @attr user [User] the user assigned to the room
# @attr room [Room] the room assigned to the user
class RoomAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :room

  has_one :group, through: :user

  validates :user, presence: true, uniqueness: true
  validates :room, presence: true

  validate :room_has_suite, if: ->(r) { r.room.present? }
  validate :user_has_group, if: ->(r) { r.user.present? }
  validate :user_and_room_have_same_suite_assignment

  # Create a RoomAssignment object for a specific group
  #
  # @param group [Group] the group in question
  # @return [RoomAssignment] a room assignment for the group's leader
  def self.from_group(group)
    new(user: group.leader)
  end

  private

  def room_has_suite
    return if room.suite.present?
    errors.add(:room, 'must have a suite before it can be assigned.')
  end

  def user_has_group
    return if user.group.present?
    errors.add(:user, 'must be in a group to be assigned a room.')
  end

  def user_and_room_have_same_suite_assignment
    return unless group&.suite.present? && room&.suite.present?
    return if group.suite == room.suite
    errors.add(:user, "must be assigned to this room's suite.")
  end
end
