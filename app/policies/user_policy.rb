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
    record&.draw&.pre_lottery? && !record.group.present? && draw_intent_state
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
    user.admin? || (!record.draw.intent_locked && (user.rep? || record == user))
  end
end
