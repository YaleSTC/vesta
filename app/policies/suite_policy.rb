# frozen_string_literal: true
# Class for Suite permissions
class SuitePolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    user.rep? || user.admin?
  end

  def index?
    true
  end

  def edit_tags?
    user.admin?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
