# frozen_string_literal: true

# Base class for permissions. Defaults to only Admin access.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user
    @user = user
    @record = record
  end

  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def create?
    user.admin?
  end

  def new?
    create?
  end

  def update?
    user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

  def superuser_dash?
    user.superuser?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope # rubocop:disable Style/Documentation
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

  def user_has_uber_permission?
    user.rep? || user.admin?
  end

  def user_is_a_group_leader(user)
    user.group.present? && user.leader_of?(user.group)
  end
end
