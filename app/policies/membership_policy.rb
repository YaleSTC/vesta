# frozen_string_literal: true

# Class for Membership permissions
class MembershipPolicy < ApplicationPolicy
  def create?
    request_to_join? || bulk_invite?
  end

  def request_to_join?
    user.group.blank? && no_current_membership(user, record.group_id) &&
      draws_match?(user, record) && record.group.draw.group_formation?
  end

  def create_invite?
    (user.leader_of?(record.group) || user_has_uber_permission?) &&
      record.group.open?
  end

  def new_invite?
    create_invite?
  end

  def update?
    accept? || finalize?
  end

  def accept?
    membership_can_be_accepted? &&
      ((user_can_affect_membership? && record.invited?) ||
      (leader_can_affect_membership? && record.requested?) ||
      user_has_uber_permission?)
  end

  def finalize?
    user_can_affect_membership? && !record.locked? && record.group.finalizing?
  end

  def destroy?
    !record.locked? && (user_can_affect_membership? ||
      leader_can_affect_membership? || user_has_uber_permission?)
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  private

  def group_not_locking?(group)
    !group.finalizing? && !group.locked?
  end

  def no_current_membership(user, group_id)
    user.memberships.where(group_id: group_id).blank?
  end

  def draws_match?(user, record)
    record.group.draw.present? && (user.draw == record.group.draw)
  end

  def membership_can_be_accepted?
    record.group.open? && !record.accepted?
  end

  def user_can_affect_membership?
    record.user == user && !user.leader_of?(record.group)
  end

  def leader_can_affect_membership?
    record.user != user && user.leader_of?(record.group) && !record.accepted?
  end
end
