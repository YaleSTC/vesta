# frozen_string_literal: true

# Model to represent clipped groups.  When two or more groups want to select
# suites at the same time a clip should be created.  This allows for all groups
# in the clip to be assigned the same lottery number and therefore allow them
# all to select suites at the same time.
#
# @attr draw [Draw] The draw that the clip is in.
# @attr groups [Array<Group>] The groups included in the clip.
class Clip < ApplicationRecord
  belongs_to :draw
  has_many :clip_memberships, dependent: :delete_all
  has_many :groups, -> { where(clip_memberships: { confirmed: true }) },
           through: :clip_memberships
  has_one :lottery_assignment, dependent: :nullify

  validate :draw_allows_clipping

  before_update ->() { throw(:abort) if will_save_change_to_draw_id? }

  # Generate the clip's name
  #
  # @return [String] the clip's name
  def name
    "#{leader.full_name}'s Clip"
  end

  # Destroys the clip if it contains too few groups. It is called
  # automatically after groups in clips are destroyed or change their draw.
  #
  # @return [Clip] the clip destroyed or nil if no change
  def cleanup!
    destroy! if existing_memberships.length <= 1
  end

  # Return the first leader of the clip
  #
  # @return [User] leader of the first group of the clip
  def leader
    groups.first&.leader || clip_memberships.first&.group&.leader
  end

  # Return how many groups are in the clip
  #
  # @return [Integer] the amount of groups in the clip
  def size
    groups.count
  end

  private

  def existing_memberships
    clip_memberships.to_a.keep_if(&:persisted?)
  end

  def draw_allows_clipping
    return if draw.allow_clipping
    errors.add(:base, 'This draw currently does not allow for clipping.')
  end
end
