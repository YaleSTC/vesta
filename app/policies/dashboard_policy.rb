# frozen_string_literal: true

# Class for Dashboard permissions.
class DashboardPolicy < ApplicationPolicy
  def show?
    true
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
