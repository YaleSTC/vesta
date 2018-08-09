# frozen_string_literal: true

# Model to represent room assignments
#
# @attr user [User] the user assigned to the room
# @attr room [Room] the room assigned to the user
class RoomAssignment < ApplicationRecord
  belongs_to :draw_membership
  belongs_to :room

  has_one :user, through: :draw_membership
  has_one :group, through: :user

  validates :draw_membership, presence: true, uniqueness: true
  validates :room, presence: true

  validate :room_has_suite, if: ->(r) { r.room.present? }
  validate :draw_membership_has_group, if: ->(r) { r.draw_membership.present? }
  validate :draw_membership_and_room_have_same_suite_assignment

  # Create a RoomAssignment object for a specific group
  #
  # @param group [Group] the group in question
  # @return [RoomAssignment] a room assignment for the group's leader
  def self.from_group(group)
    new(draw_membership: group.leader_draw_membership)
  end

  private

  def room_has_suite
    return if room.suite.present?
    errors.add(:room, 'must have a suite before it can be assigned.')
  end

  def draw_membership_has_group
    return if draw_membership.group.present?
    errors.add(:user, 'must be in a group to be assigned a room.')
  end

  def draw_membership_and_room_have_same_suite_assignment
    return unless group&.suite.present? && room&.suite.present?
    return if group.suite == room.suite
    errors.add(:user, "must be assigned to this room's suite.")
  end
end
