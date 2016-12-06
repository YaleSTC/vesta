# frozen_string_literal: true
class TaggablePolicy < ApplicationPolicy
  def edit_tags?
    user.admin?
  end

  def add_tag?
    edit_tags?
  end

  def remove_tag?
    edit_tags?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
