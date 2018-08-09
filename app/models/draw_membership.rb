# frozen_string_literal: true

# Class to represent the membership of a user in a draw. A user can have
#   multiple draw_memberships but can only have one draw_membership that is
#   active at any time.
#
# @attr user [User] the user joined to the draw
# @attr draw [Draw] the draw joined to the user
# @attr active [Boolean] whether or not this is an active draw_membership
# @attr intent [Integer] an enum for the user's housing intent, on_campus,
#   off_campus, or undeclared (required)
class DrawMembership < ApplicationRecord
  belongs_to :user
  belongs_to :draw

  has_one :led_group, inverse_of: :leader_draw_membership, dependent: :destroy,
                      class_name: 'Group',
                      foreign_key: :leader_draw_membership_id
  has_one :membership, -> { where(status: 'accepted') }, dependent: :destroy
  accepts_nested_attributes_for :membership
  has_one :group, through: :membership
  has_many :memberships, dependent: :destroy
  has_one :room_assignment, dependent: :destroy
  has_one :room, through: :room_assignment

  before_validation :freeze_user_id, if: -> { will_save_change_to_user_id? }
  validates :user, presence: true, uniqueness: { scope: :draw }
  validates :intent, presence: true
  validate :validate_only_one_active_draw_membership

  enum intent: %w(undeclared on_campus off_campus)

  # Back up a user's current draw into old_draw_id and removes them from current
  # draw, also setting intent to undeclared. Does nothing if draw_id is nil.
  #
  # @return [DrawMembership] the modified but unpersisted user object
  def remove_draw
    return self if draw_id.nil?
    old_draw_id = draw_id
    assign_attributes(draw_id: nil, old_draw_id: old_draw_id,
                      intent: 'undeclared')
    self
  end

  # Restores a user's draw from old_draw_id and optionally saves the current
  # draw_id to old_draw_id, also setting intent to undeclared. If the draw_id is
  # equal to the old_draw_id, will set draw_id to nil.
  #
  # @param save_current [Boolean] whether or not to assign the current draw_id
  #   value to old_draw_id, defaults to false
  # @return [DrawMembership] the modified but unpersisted user object
  def restore_draw(save_current: false)
    to_save = save_current ? draw_id : nil
    new_draw_id = old_draw_id != draw_id ? old_draw_id : nil
    assign_attributes(draw_id: new_draw_id, old_draw_id: to_save,
                      intent: 'undeclared')
    self
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
  def validate_only_one_active_draw_membership
    return unless user.present?
    return unless active?
    base_query = DrawMembership.where(user: user, active: true)
    return if persisted? && base_query.where.not(id: id).count <= 1
    return if !persisted? && base_query.count.zero?
    errors.add(:user, 'can only be in one active draw.')
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize

  def freeze_user_id
    return unless persisted?
    handle_abort('cannot change the assigned user.')
  end
end
