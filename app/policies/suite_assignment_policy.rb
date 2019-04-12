# frozen_string_literal: true

# Policy for SuiteAssignments
class SuiteAssignmentPolicy < ApplicationPolicy
  def create?
    return can_drawless_assign? unless draw.present?
    return false unless draw.suite_selection? || draw.results?
    return student_can_select_suite? if draw.student_selection? &&
                                        draw.suite_selection?
    # implicit admin single selection
    user_has_uber_permission?
  end

  def new?
    create?
  end

  def destroy?
    user_has_uber_permission?
  end

  def bulk_assign?
    user_has_uber_permission? && draw.admin_selection? && draw.suite_selection?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  private

  def draw
    record&.group&.draw
  end

  def can_drawless_assign?
    user.admin?
  end

  def student_can_select_suite?
    user.leader_of?(record.group) && draw.next_group?(record.group)
  end
end
