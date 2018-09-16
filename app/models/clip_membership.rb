# frozen_string_literal: true

# Join model between groups and clips.
# @attr group [Group] The group of the membership.
# @attr clip [Clip] The clip of the membership.
# @attr confirmed [Boolean] Confirmation for membership. Defaults to false.
class ClipMembership < ApplicationRecord
  belongs_to :group
  belongs_to :clip

  validates :group, presence: true, uniqueness: { scope: :clip }
  validates :clip, presence: true
  validate :matching_draw, if: ->(m) { m.clip.present? && m.group.present? }
  validate :group_not_in_clip, if: ->(m) { m.group.present? }, on: :create

  after_save :destroy_pending,
             if: ->() { saved_change_to_confirmed && confirmed }

  after_destroy :run_clip_cleanup

  private

  def run_clip_cleanup
    clip.cleanup!
  end

  def matching_draw
    return if group.draw == clip.draw
    errors.add :base, "#{group.name} is not in the same draw as the clip"
  end

  def group_not_in_clip
    return unless group.clip
    errors.add :base, "#{group.name} already belongs to another clip"
  end

  def destroy_pending
    group.clip_memberships.where.not(id: id).destroy_all
  end
end
