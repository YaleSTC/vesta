# frozen_string_literal: true

# Policy for email exports
class EmailExportPolicy < ApplicationPolicy
  def create?
    user.admin? || user.rep?
  end
end
