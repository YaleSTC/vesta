# frozen_string_literal: true

# Class for Draw permissions
class DrawPolicy < ApplicationPolicy
  def show?
    user.admin? || user.rep? || !record.draft?
  end

  def index?
    true
  end

  def activate?
    edit? && record.draft?
  end

  def intent_report?
    user.admin? || user.rep?
  end

  def filter_intent_report?
    intent_report?
  end

  def suite_summary?
    show?
  end

  def suites_edit?
    suites_update?
  end

  def suites_update?
    update? || user.rep?
  end

  def student_summary?
    edit?
  end

  def students_update?
    edit?
  end

  def group_actions?
    (user.admin? && !record.draft?) || record.pre_lottery?
  end

  def intent_actions?
    user.admin? || user.rep?
  end

  def reminder?
    record.pre_lottery? && !user.student?
  end

  def intent_reminder?
    return false unless record.intent_deadline
    reminder? && Time.zone.today <= record.intent_deadline
  end

  def locking_reminder?
    return false unless record.locking_deadline
    reminder? && Time.zone.today > record.intent_deadline
  end

  def bulk_on_campus?
    edit? && record.before_lottery? && !record.all_intents_declared?
  end

  def lock_intent?
    edit? && record.all_intents_declared?
  end

  def oversub_report?
    record.pre_lottery? && !record.suites.empty?
  end

  def group_report?
    !record.groups.empty?
  end

  def start_lottery?
    edit? && record.pre_lottery?
  end

  def lottery_confirmation?
    start_lottery?
  end

  def oversubscription?
    (user.admin? || user.rep?) && record.pre_lottery?
  end

  def toggle_size_lock?
    (user.admin? || user.rep?)
  end

  def lock_all_sizes?
    edit?
  end

  def lottery?
    record.lottery? && (user.admin? || user.rep?)
  end

  def start_selection?
    edit? && record.lottery?
  end

  def select_suites?
    record.suite_selection? && (user.admin? || user.rep?)
  end

  def assign_suites?
    select_suites?
  end

  def results?
    (user.admin? || user.rep?) && record.results?
  end

  def selection_metrics?
    record.suite_selection? && user.draw == record && user.group.present?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
