# frozen_string_literal: true
# Class for User permissions
class UserPolicy < ApplicationPolicy
  def show?
    user.admin? || user == record
  end

  def update?
    show?
  end

  def edit?
    show?
  end

  def edit_intent?
    show?
  end

  def update_intent?
    show?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
