# frozen_string_literal: true

# Policies for updating students
class DrawStudentPolicy < ApplicationPolicy
  def edit?
    user.admin?
  end

  def update?
    edit?
  end

  def bulk_assign?
    user.admin?
  end
end
