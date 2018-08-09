# frozen_string_literal: true

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
# @attr locked [Boolean] Confirmation for membership. Defaults to false.
#   (requested, invited, accepted)
class Membership < ApplicationRecord
  belongs_to :group
  belongs_to :draw_membership

  has_one :user, through: :draw_membership, source: :user
  has_one :draw, through: :draw_membership, source: :draw

  enum status: %w(accepted invited requested)

  validates :group, presence: true
  validates :draw_membership, presence: true, uniqueness: { scope: :group }

  validates :status, presence: true
  validate :matching_draw, if: ->(m) { m.draw.present? && m.group.present? }
  validate :user_on_campus, if: ->(m) { m.draw_membership.present? }
  validate :group_is_open, if: ->(m) { m.group.present? }, on: :create
  validate :user_not_in_group, if: ->(m) { m.draw_membership.present? },
                               on: :create
  validate :lockable?, if: ->(m) { m.group.present? }

  before_destroy do |m|
    handle_abort('Cannot destroy locked membership') if m.locked?
  end
  before_update do |m|
    handle_abort('Cannot edit locked membership') if m.locked?
  end
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
  after_destroy :run_group_cleanup
  after_save :destroy_pending, if: ->() { accepted? }

  def locked?
    # we need to allow the membership to be locked
    will_save_change_to_locked? ? false : locked
  end

  private

  def user_not_in_group
    return unless draw_membership.group.present? && \
                  draw_membership.group != group
    errors.add :base, "#{user.full_name} already belongs to another group"
  end

  def update_group_status
    group.update_status!
  end

  def freeze_group_and_user
    return unless will_save_change_to_group_id? || \
                  will_save_change_to_draw_membership_id?
    handle_abort('Cannot change group or user associated with this membership')
  end

  def freeze_accepted_status
    return unless will_save_change_to_status? &&
                  status_in_database == 'accepted'
    handle_abort('Cannot change membership status after acceptance')
  end

  def matching_draw
    return if draw_membership.draw == group.draw
    errors.add :base, "#{user.full_name} is not in the same draw as the group"
  end

  def group_is_open
    return unless !persisted? || will_save_change_to_status?
    errors.add :group, 'cannot accept additional members' unless group.open?
  end

  def user_on_campus
    return if draw_membership.on_campus?
    msg = "#{draw_membership.user.full_name} is not living on campus"
    errors.add :base, msg
  end

  def lockable?
    return unless will_save_change_to_locked? && locked
    errors.add :locked, 'must be an accepted membership' unless accepted?
    errors.add :locked, 'must be a finalizing group' unless group.finalizing?
  end

  def destroy_pending
    return unless saved_change_to_status || saved_change_to_id
    draw_membership.memberships.where.not(id: id).destroy_all
  end

  def update_counter_cache
    return unless saved_change_to_status
    increment_counter_cache
  end

  # rubocop:disable Rails/SkipsModelValidations
  def increment_counter_cache
    group.increment!(:memberships_count) if accepted?
  end

  def decrement_counter_cache
    group.decrement!(:memberships_count) if accepted?
  end
  # rubocop:enable Rails/SkipsModelValidations

  def run_group_cleanup
    group.cleanup!
  end
end
