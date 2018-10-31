# frozen_string_literal: true

# Class for SuiteImport permissions.
class SuiteImportFormPolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
