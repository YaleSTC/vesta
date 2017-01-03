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
class Membership < ApplicationRecord
  belongs_to :group, counter_cache: true
  belongs_to :user

  validates :group, presence: true
  validates :user, presence: true
  validate :matching_draw, if: ->(m) { m.user.present? && m.group.present? }
  validate :user_on_campus, if: ->(m) { m.user.present? }
  validate :group_is_open, if: ->(m) { m.group.present? }, on: :create

  before_destroy ->(m) { throw(:abort) if m.readonly? }
  before_update ->(m) { throw(:abort) if m.readonly? }
  before_update :freeze_group_and_user
  after_create :update_group_status
  after_destroy :update_group_status

  def readonly?
    group.locked?
  end

  private

  def update_group_status
    group.update_status
  end

  def freeze_group_and_user
    return unless group_id_changed? || user_id_changed?
    throw(:abort)
  end

  def matching_draw
    return if user.draw == group.draw
    errors.add :user, 'Member draw and group draw must match'
  end

  def group_is_open
    errors.add :group, 'Group must be open' unless group.open?
  end

  def user_on_campus
    return if user.on_campus?
    errors.add :user, 'User must be living on campus to join a group'
  end
end
