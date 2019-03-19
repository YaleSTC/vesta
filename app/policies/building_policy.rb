# frozen_string_literal: true

# Class for Building permissions.
class BuildingPolicy < ApplicationPolicy
  # We are currently exclusively inheriting behaviour from ApplicationPolicy.

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
