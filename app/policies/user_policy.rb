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
    user.admin? || (user == record && user.draw.try(:pre_lottery?))
  end

  def update_intent?
    edit_intent?
  end

  def build?
    new?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
