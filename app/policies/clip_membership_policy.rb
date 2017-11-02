# frozen_string_literal: true

# Class for Clip permissions
class ClipMembershipPolicy < ApplicationPolicy
  def update?
    user_is_a_group_leader(user) && membership_is_for_this_group(user, record)\
      && record.group.draw.pre_lottery?
  end

  def destroy?
    update?
  end

  def accept?
    update? && !record.confirmed
  end

  def reject?
    destroy? && !record.confirmed
  end

  def leave?
    destroy? && record.confirmed
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  private

  def membership_is_for_this_group(user, record)
    user.group == record.group
  end
end
