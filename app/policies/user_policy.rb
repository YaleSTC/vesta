# frozen_string_literal: true

# Class for User permissions
class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit_intent?
    update_intent?
  end

  def update_intent?
    user.admin? || user.rep? ||
      (user == record && !user.group && draw_intent_state)
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
