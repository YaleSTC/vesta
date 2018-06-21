# frozen_string_literal: true

# Class for User permissions
class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    update?
  end

  def update?
    user.admin?
  end

  def edit_password?
    update_password?
  end

  def update_password?
    (record == user) && !User.cas_auth?
  end

  def edit_intent?
    update_intent?
  end

  def update_intent?
    (valid_student_rep_update || valid_admin_update) && !record.group.present?
  end

  def build?
    new?
  end

  def draw_info?
    !record.admin? && record.draw_id.present?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  private

  def valid_student_rep_update
    (user.rep? || record == user) && record&.draw&.pre_lottery? &&
      !record.draw.intent_locked
  end

  def valid_admin_update
    user.admin? && record&.draw&.before_lottery?
  end
end
