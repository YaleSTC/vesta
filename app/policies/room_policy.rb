# frozen_string_literal: true
# Class for Room permissions
class RoomPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    user.rep? || user.admin?
  end

  def index?
    user.rep? || user.admin?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
