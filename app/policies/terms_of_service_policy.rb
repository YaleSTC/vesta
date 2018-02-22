# frozen_string_literal: true

# Class for User permissions
class TermsOfServicePolicy < ApplicationPolicy
  def show?
    true
  end

  def accept?
    user.tos_accepted.nil? && !user.admin?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
