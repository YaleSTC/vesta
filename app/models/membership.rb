# frozen_string_literal: true
#
# Model for relationships between Groups and Users.
# Updates the group status on creation and destruction.
# Validations:
#   - Users can only join groups in their draw
#   - Groups can only be joined when they are open
#   - Users must have declared on_campus intent
#
# @attr group [Group] The group of the membership.
# @attr user [User] The user of the membership.
# @attr status [Integer] Enum for membership status.
#   (requested, invited, accepted)
class Membership < ApplicationRecord
  belongs_to :group
  belongs_to :user

  enum status: %w(accepted invited requested)

  validates :group, presence: true
  validates :user, presence: true, uniqueness: { scope: :group }
  validates :status, presence: true
  validate :matching_draw, if: ->(m) { m.user.present? && m.group.present? }
  validate :user_on_campus, if: ->(m) { m.user.present? }
  validate :group_is_open, if: ->(m) { m.group.present? }, on: :create
  validate :user_not_in_group, if: ->(m) { m.user.present? }

  before_destroy ->(m) { throw(:abort) if m.readonly? }
  before_update ->(m) { throw(:abort) if m.readonly? }
  before_update :freeze_group_and_user
  before_update :freeze_accepted_status

  # Group memberships_count counter cache callbacks
  # MUST come before the status callbacks
  after_save :update_counter_cache
  after_create :increment_counter_cache
  after_destroy :decrement_counter_cache

  # Group status callbacks
  after_create :update_group_status
  after_destroy :update_group_status

  def readonly?
    group.locked?
  end

  private

  def user_not_in_group
    return unless user.group
    errors.add :user, 'already has membership in another group'
  end

  def update_group_status
    group.update_status
  end

  def freeze_group_and_user
    return unless group_id_changed? || user_id_changed?
    throw(:abort)
  end

  def freeze_accepted_status
    return unless status_changed? && status_was == 'accepted'
    throw(:abort)
  end

  def matching_draw
    return if user.draw == group.draw
    errors.add :user, 'must belong to same draw as group'
  end

  def group_is_open
    errors.add :group, 'must be open' unless group.open?
  end

  def user_on_campus
    return if user.on_campus?
    errors.add :user, 'must be living on campus to join a group'
  end

  def update_counter_cache
    return unless status_changed?
    increment_counter_cache
  end

  def increment_counter_cache
    group.increment!(:memberships_count) if accepted?
  end

  def decrement_counter_cache
    group.decrement!(:memberships_count) if accepted?
  end
end
