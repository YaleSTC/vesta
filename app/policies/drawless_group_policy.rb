# frozen_string_literal: true
#
# Policy for permissions on special (non-draw) housing groups
class DrawlessGroupPolicy < ApplicationPolicy
  def select_suite?
    user.admin? && record.locked?
  end

  def show?
    record.members.include?(user) || super
  end

  def lock?
    user.admin? && record.full?
  end
end
