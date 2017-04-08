# frozen_string_literal: true

# Class for Suite permissions
class SuitePolicy < ApplicationPolicy
  def show?
    !record.medical || user&.group&.suite == record || user.admin?
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

  def unmerge?
    record.rooms.map(&:original_suite).none?(&:blank?) && edit?
  end

  def view_draw?
    edit?
  end

  def medical?
    user.admin?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
