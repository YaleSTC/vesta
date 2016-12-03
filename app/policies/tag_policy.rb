# frozen_string_literal: true
class TagPolicy < ApplicationPolicy
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
