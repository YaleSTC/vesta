# frozen_string_literal: true
# Class for Group permissions
class GroupPolicy < ApplicationPolicy
  def show?
    true
  end

  def index?
    true
  end

  def create?
    (user.draw && !user.group) || user.admin?
  end

  def edit?
    record.leader == user || user.admin?
  end

  def destroy?
    edit?
  end

  def update?
    edit?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
