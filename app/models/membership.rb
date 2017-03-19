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
  validate :user_not_in_group, if: ->(m) { m.user.present? }, on: :create
  validate :lockable?, if: ->(m) { m.group.present? }

  before_destroy ->(m) { throw(:abort) if m.readonly? }
  before_update ->(m) { throw(:abort) if m.readonly? }
  before_update :freeze_group_and_user
  before_update :freeze_accepted_status

  # Group memberships_count counter cache callbacks
  # MUST come before the status callbacks
  after_save :update_counter_cache
  after_create :increment_counter_cache
  after_destroy :decrement_counter_cache, if: ->(m) { m.group.present? }

  # Group status callbacks
  after_save :update_group_status
  after_destroy :update_group_status, if: ->(m) { m.group.present? }

  after_save :send_joined_email, if: ->() { status_changed? && accepted? }
  after_destroy :send_left_email, if: ->() { accepted? }

  def readonly?
    if locked_changed?
      # we need to allow the membership to be locked
      false
    else
      locked
    end
  end

  private

  def user_not_in_group
    return unless user.group && user.group != group
    errors.add :base, "#{user.full_name} already belongs to another group"
  end

  def update_group_status
    group.update_status!
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
    errors.add :base, "#{user.full_name} is not in the same draw as the group"
  end

  def group_is_open
    return unless !persisted? || status_changed?
    errors.add :group, 'must be open' unless group.open?
  end

  def user_on_campus
    return if user.on_campus?
    errors.add :base, "#{user.full_name} is not living on campus"
  end

  def lockable?
    return unless locked_changed? && locked
    errors.add :locked, 'must be an accepted membership' unless accepted?
    errors.add :locked, 'must be a finalizing group' unless group.finalizing?
  end

  def send_joined_email
    StudentMailer.joined_group(joined: user, group: group,
                               college: College.first).deliver_later
  end

  def send_left_email
    StudentMailer.left_group(left: user, group: group,
                             college: College.first).deliver_later
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
