# frozen_string_literal: true

# Policies for College resources / actions
class CollegePolicy < ApplicationPolicy
  def index?
    false
  end

  def create?
    user.superuser?
  end

  def destroy?
    false
  end
end
