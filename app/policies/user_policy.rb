# frozen_string_literal: true
# Class for User permissions
class UserPolicy < ApplicationPolicy
  def show?
    user.admin? || user == record
  end

  def update?
    show?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
