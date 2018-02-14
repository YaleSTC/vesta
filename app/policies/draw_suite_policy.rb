# frozen_string_literal: true

# Policies for DrawSuites resources / actions
class DrawSuitePolicy < ApplicationPolicy
  def index?
    (!record.draw.draft? && user.student?) || user_has_uber_permission?
  end

  def edit_collection?
    update_collection?
  end

  def update_collection?
    user_has_uber_permission? && record.draw.before_lottery?
  end
end
