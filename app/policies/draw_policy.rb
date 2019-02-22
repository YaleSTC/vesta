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

  def duplicate?
    create?
  end

  def proceed_to_group_formation?
    edit? && record.intent_selection?
  end

  def group_actions?
    user.admin? || record.group_formation?
  end

  def intent_actions?
    (user.admin? || user.rep?) && record.before_lottery?
  end

  def intent_editable?
    record.group_formation? || record.intent_selection?
  end

  def reminder?
    record.group_formation? || record.intent_selection? \
      && user_has_uber_permission?
  end

  def intent_reminder?
    record.intent_selection? && user_has_uber_permission?
  end

  def locking_reminder?
    record.group_formation? && user_has_uber_permission?
  end

  def bulk_on_campus?
    edit? && record.before_lottery? && !record.all_intents_declared?
  end

  def lock_intent?
    edit? && record.all_intents_declared?
  end

  def oversub_report?
    record.group_formation? && !record.suites.empty?
  end

  def group_report?
    true
  end

  def start_lottery?
    edit? && record.group_formation?
  end

  def lottery_confirmation?
    start_lottery?
  end

  def oversubscription?
    (user.admin? || user.rep?) && record.group_formation?
  end

  def toggle_size_restrict?
    (user.admin? || user.rep?)
  end

  def restrict_all_sizes?
    edit?
  end

  def lock_all_groups?
    edit?
  end

  def prune?
    # the #oversubscribed? comes from the DrawReport -- this will fail
    # if a plain draw object is passed
    user.admin? && record.group_formation? && record.oversubscribed?
  end

  def start_selection?
    edit? && record.lottery?
  end

  def results?
    (user.admin? || user.rep?) && record.results?
  end

  def selection_metrics?
    record.suite_selection? && user.draw == record && user.group.present?
  end

  def group_export?
    record.lottery_or_later? && user_has_uber_permission?
  end

  def archive?
    destroy? && record.active?
  end

  def browsable?
    record.active?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
