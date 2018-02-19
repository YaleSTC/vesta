# frozen_string_literal: true

# Class for LotteryAssignment permissions
class LotteryAssignmentPolicy < ApplicationPolicy
  def index?
    record.draw.lottery? && user_has_uber_permission?
  end

  def create?
    record.draw.lottery? && user_has_uber_permission?
  end

  def update?
    create?
  end

  def automatic?
    user.admin? && record.draw.lottery?
  end

  def export?
    record.draw.lottery_or_later? && user_has_uber_permission?
  end
end
