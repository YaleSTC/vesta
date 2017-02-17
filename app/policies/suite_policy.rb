# frozen_string_literal: true
# Class for Suite permissions
class SuitePolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    user.rep? || user.admin?
  end

  def update?
    edit?
  end

  def index?
    true
  end

  def deactivate?
    edit?
  end

  def activate?
    edit?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
