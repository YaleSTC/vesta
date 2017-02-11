# frozen_string_literal: true
# Class for Group permissions
class GroupPolicy < ApplicationPolicy
  def show?
    true
  end

  def index?
    true
  end

  def create?
    (user.draw && !user.group) || user.admin?
  end

  def edit?
    record.leader == user || user.admin?
  end

  def destroy?
    edit?
  end

  def update?
    edit?
  end

  def request_to_join?
    (user.draw == record.draw) && !user.group
  end

  def accept_request?
    edit?
  end

  def invite_to_join?
    edit?
  end

  def edit_invitations?
    edit?
  end

  def accept_invitation?
    !user.group && record.invitations.include?(user)
  end

  def finalize?
    edit? && record.full?
  end

  def finalize_membership?
    (user.group == record && !record.locked_members.include?(user)) &&
      record.finalizing?
  end

  def lock?
    user.admin?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
