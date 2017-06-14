# frozen_string_literal: true

# Class for Group permissions
class GroupPolicy < ApplicationPolicy # rubocop:disable ClassLength
  def show?
    true
  end

  def index?
    true
  end

  def create?
    student_can_create_group(user) || user_has_uber_permission?
  end

  def edit?
    update?
  end

  def advanced_edit?
    user_has_uber_permission?
  end

  def destroy?
    edit?
  end

  def update?
    (record.leader == user && group_can_be_edited_by_leader?(record)) ||
      user_has_uber_permission?
  end

  def request_to_join?
    (user.draw == record.draw) && !user.group
  end

  def accept_request?
    edit?
  end

  def send_invites?
    invite?
  end

  def invite?
    (record.leader == user || user_has_uber_permission?) && record.open?
  end

  def reject_pending?
    edit?
  end

  def accept_invitation?
    !user.group && record.invitations.include?(user)
  end

  def leave?
    !record.locked? && record.members.include?(user) && record.leader != user
  end

  def finalize?
    edit? && record.full?
  end

  def finalize_membership?
    (user.group == record && !record.locked_members.include?(user)) &&
      record.finalizing?
  end

  def lock?
    user_has_uber_permission? && !record.open? && !record.locked?
  end

  def unlock?
    user_has_uber_permission? && record.unlockable?
  end

  def assign_lottery?
    record.locked? && (user.admin? || user.rep?)
  end

  def view_pending_members?
    edit? || user.rep?
  end

  def change_leader?
    edit?
  end

  def make_drawless?
    user.admin?
  end

  def assign_rooms?
    user_can_assign_rooms?(user, record) && room_assignment_eligible?(record)
  end

  def edit_room_assignment?
    user.admin? && rooms_assigned?(record)
  end

  def select_suite?
    user_has_uber_permission? ||
      student_can_select_suite?
  end

  def assign_suite?
    select_suite?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  private

  def student_can_select_suite?
    return false unless record.draw.student_selection?
    user.leader_of?(record) && record.draw.next_group?(record)
  end

  def group_can_be_edited_by_leader?(group)
    !group.finalizing? && !group.locked?
  end

  def student_can_create_group(user)
    (user.draw && user.draw.pre_lottery? && user.on_campus? && !user.group)
  end

  def user_can_assign_rooms?(user, group)
    user_has_uber_permission? ||
      (user.group == group && group.leader == user)
  end

  def room_assignment_eligible?(group)
    group.suite.present? && !rooms_assigned?(group)
  end

  def rooms_assigned?(group)
    group.leader.room_id.present?
  end
end
