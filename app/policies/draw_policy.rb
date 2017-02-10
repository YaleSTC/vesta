# frozen_string_literal: true
#
# Class for Draw permissions
class DrawPolicy < ApplicationPolicy
  def show?
    true
  end

  def activate?
    edit? && record.draft?
  end

  def intent_report?
    edit?
  end

  def filter_intent_report?
    intent_report?
  end

  def suite_summary?
    show?
  end

  def group_actions?
    user.admin? || record.pre_lottery?
  end

  def intent_summary?
    !record.draft?
  end

  def oversub_report?
    !record.draft? && !record.suites.empty?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
