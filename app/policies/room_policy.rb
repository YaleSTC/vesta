# frozen_string_literal: true

# Class for Room permissions
class RoomPolicy < ApplicationPolicy
  # We are currently keeping the ability to view Rooms to admins only.

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
