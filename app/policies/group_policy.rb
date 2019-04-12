# frozen_string_literal: true

# Class for Group permissions
class GroupPolicy < ApplicationPolicy
  def show?
    true
  end

  def index?
    user_has_uber_permission?
  end

  def create?
    student_can_create_group(user) || user_has_uber_permission?
  end

  def update?
    (user.leader_of?(record) && group_can_be_edited_by_leader?(record)) ||
      user_has_uber_permission?
  end

  def advanced_edit?
    user_has_uber_permission?
  end

  def destroy?
    update?
  end

  def finalize?
    update? && record.full? && !record.finalizing? && !record.locked?
  end

  def lock?
    user_has_uber_permission? && !record.open? && !record.locked?
  end

  def unlock?
    user_has_uber_permission? && record.unlockable?
  end

  def view_pending_members?
    update?
  end

  def change_leader?
    update?
  end

  def make_drawless?
    user.admin?
  end

  def skip?
    user.admin? && record.draw.suite_selection?
  end

  def select_suite?
    user_has_uber_permission? ||
      student_can_select_suite?
  end

  def assign_suite?
    select_suite?
  end

  def reassign_suite?
    assign_suite? && (record.draw.suite_selection? || record.draw.results?)
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
    (user.draw && user.draw.group_formation? && \
      user.draw_membership.on_campus? && user.group.blank?)
  end
end
