# frozen_string_literal: true

# Policy for assigning rooms
class RoomAssignmentPolicy < ApplicationPolicy
  def create?
    new? || edit?
  end

  def new?
    user_can_assign_rooms?(user, record) && room_assignment_eligible?(record)
  end

  def confirm?
    new?
  end

  def edit?
    user.admin? && rooms_assigned?(record.group)
  end

  def update?
    edit?
  end

  private

  def user_can_assign_rooms?(user, record)
    user_has_uber_permission? ||
      (user.group == record.group && record.group.leader == user)
  end

  def room_assignment_eligible?(record)
    record.group.suite.present? && !rooms_assigned?(record.group)
  end

  def rooms_assigned?(group)
    group.members.all? { |m| m.room.present? }
  end
end
