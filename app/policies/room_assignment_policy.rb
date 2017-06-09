# frozen_string_literal: true

# Policy for assigning rooms
class RoomAssignmentPolicy < ApplicationPolicy
  def create?
    new? || edit?
  end

  def new?
    GroupPolicy.new(user, record.group).assign_rooms?
  end

  def confirm?
    new?
  end

  def edit?
    GroupPolicy.new(user, record.group).edit_room_assignment?
  end
end
