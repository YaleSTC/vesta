# frozen_string_literal: true

# Class for Intents permissions
class IntentPolicy < ApplicationPolicy
  def report?
    user.admin? || user.rep?
  end

  def export?
    report?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
