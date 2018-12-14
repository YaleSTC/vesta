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

  def access?
    user.superadmin? || user.college_id == record.id
  end

  def archive?
    create?
  end
end
