# frozen_string_literal: true

# Model to assign lottery numbers to groups
#
# @attr number [Integer] the position in the lottery
# @attr selected [Boolean] whether the associated group has selected a suite
# @attr group [Group] the group the lottery number is for
# @attr draw [Draw] the draw the lottery number is in
class LotteryAssignment < ApplicationRecord
  belongs_to :draw
  has_many :groups, dependent: :nullify
  belongs_to :clip

  validates :number,
            presence: true,
            numericality: { only_integer: true },
            uniqueness: { scope: :draw }
  validates :selected, inclusion: { in: [false, true] }

  validates :draw, presence: true
  validate :draw_in_lottery, on: :create, if: ->() { draw.present? }

  validate :groups_presence
  validate :groups_in_draw, if: ->() { draw.present? }

  after_create :assign_groups_if_clipped!, if: ->() { clip.present? }

  before_update :freeze_draw
  before_update :freeze_number, unless: ->() { draw.lottery? }

  # Updates the selected attribute appropriately, if necessary
  # Raises an exception if the update failed
  #
  # @return [true, nil] true when the update succeeds, nil if no update occurred
  def update_selected!
    if groups.any? { |g| g.suite.nil? } && selected
      update!(selected: false)
    elsif groups.all? { |g| g.suite.present? } && !selected
      update!(selected: true)
    end
  end

  # Returns the singular group for the lottery assignment or nil
  #
  # @return [Group,nil] the group associated with the lottery assignment if
  #   there is only one, otherwise nil
  def group
    return nil if groups.count > 1
    groups.first
  end

  # Return the "leader" of the lottery assignment for display purposes, either
  # delegating to the clip if it's present or to the first group otherwise
  #
  # @return [User] the leader of the clip or first group
  def leader
    return clip.leader if clip.present?
    groups.first.leader
  end

  # Return a "name" for the lottery assignment; states whether it is for a clip
  # or a group
  #
  # @return [String] the lottery assignment's name
  def name
    suffix = clip.present? ? "'s clip" : "'s group"
    leader.full_name + suffix
  end

  # Utility method to destroy a lottery assignment following the destruction of
  # its groups. Replaces a `dependent: :destroy` callback in Group since we
  # only want this to happen if there are no groups left.
  def process_group_destruction!
    destroy! unless reload.groups.present?
  end

  private

  def groups_presence
    return if groups.present?
    errors.add(:groups, 'must have at least one group')
  end

  def groups_in_draw
    return unless groups.any? { |g| g.draw != draw }
    errors.add(:groups, 'must be in the same draw')
  end

  def draw_in_lottery
    return if draw.lottery?
    errors.add(:draw, 'must be in lottery phase')
  end

  def freeze_draw
    return unless will_save_change_to_draw_id?
    throw(:abort)
  end

  def freeze_number
    return unless will_save_change_to_number?
    throw(:abort)
  end

  def assign_groups_if_clipped!
    clip.groups.each { |g| g.reload.update!(lottery_assignment: self) }
  end
end
