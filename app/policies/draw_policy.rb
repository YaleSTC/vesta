# frozen_string_literal: true
#
# Class for Draw permissions
class DrawPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    user.rep? || user.admin?
  end

  def activate?
    user.admin? && record.draft?
  end

  def intent_report?
    user.admin?
  end

  def filter_intent_report?
    intent_report?
  end

  def group_actions?
    user.admin? || record.pre_lottery?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
