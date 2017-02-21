# frozen_string_literal: true
# Class for Suite permissions
class SuitePolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    user.rep? || user.admin?
  end

  def index?
    true
  end

  def merge?
    perform_merge?
  end

  def perform_merge?
    edit?
  end

  def build_split?
    split?
  end

  def split?
    perform_split?
  end

  def perform_split?
    edit? && record.rooms.size >= 2
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
