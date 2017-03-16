# frozen_string_literal: true
# Class for User permissions
class UserPolicy < ApplicationPolicy
  def show?
    user.admin? || user == record
  end

  def update?
    edit?
  end

  def edit?
    user.admin?
  end

  def edit_intent?
    user.admin? || (user == record && !user.group && draw_intent_state)
  end

  def update_intent?
    edit_intent?
  end

  def build?
    new?
  end

  def draw_info?
    !record.admin? && record.draw_id.present?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  private

  def draw_intent_state
    return false unless user.draw
    !user.draw.intent_locked && !user.draw.draft?
  end
end
