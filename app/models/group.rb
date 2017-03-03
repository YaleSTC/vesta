# frozen_string_literal: true
#
# Model for Housing Groups
#
# @attr size [Integer] The room size that the Group wants.
# @attr status [String] The state of the group (open, full, finalizing,
#   or locked)
# @attr leader [User] The student that represents the Group.
# @attr members [Array<User>] The members of the group, excluding the leader.
# @attr draw [Draw] The Draw that this Group is in.
# @attr memberships_count [Integer] the number of accepted memberships (counter
#   cache)
# @attr transfers [Integer] the number of transfer students in the group
# @attr lottery_number [Integer] the lottery number assigned to the group
class Group < ApplicationRecord
  belongs_to :leader, class_name: 'User'
  belongs_to :draw
  has_one :suite
  has_many :memberships, dependent: :delete_all
  has_many :full_memberships, -> { where(status: 'accepted') },
           class_name: 'Membership', inverse_of: :group
  has_many :members, through: :full_memberships, source: :user

  enum status: %w(open full finalizing locked)

  # validates :draw, presence: true
  validates :status, presence: true
  validates :size, presence: true
  validates :leader, presence: true, inclusion: { in: ->(g) { g.members } }
  validates :memberships_count, numericality: { greater_than_or_equal_to: 0 }
  validates :transfers, presence: true,
                        numericality: { greater_than_or_equal_to: 0,
                                        only_integer: true }
  validates :lottery_number, numericality: { allow_nil: true }

  validate :validate_suite_size_inclusion
  validate :validate_members_count, if: ->(g) { g.size.present? }
  validate :validate_status, if: ->(g) { g.size.present? }

  before_validation :add_leader_to_members, if: ->(g) { g.leader.present? }

  after_destroy :restore_member_draws, if: ->(g) { g.draw.nil? }

  attr_reader :remove_ids

  # Generate the group name
  #
  # @return [String] the group's name
  def name
    year_str = leader.class_year.present? ? " (#{leader.class_year})" : ''
    "#{leader.full_name}'s Group" + year_str
  end

  # Updates the status to match the group size (open when fewer members than
  # the size, and full when they are the same)
  def update_status!
    if members_count < size
      update!(status: 'open')
    elsif members_count == size
      update!(status: 'full') if open?
      update!(status: 'locked') if lockable?
    end
  end

  # Get the group's membership requests
  #
  # @return [Array<User>] the users who have requested to join the housing group
  def requests
    memberships.where(status: 'requested').map(&:user)
  end

  # Get the group's membership invitations
  #
  # @return [Array<User>] the users who have been invited to join the group
  def invitations
    memberships.where(status: 'invited').map(&:user)
  end

  # Get the group's members that can be removed
  #
  # @return[Array<User>] the members of the group with the exception of the
  #   group leader
  def removable_members
    members.reject { |u| u.id == leader_id }
  end

  # Get the group's locked/finalized members
  #
  # @return [Array<User>] the users who have locked their membership
  def locked_members
    full_memberships.where(locked: true).map(&:user)
  end

  # Check if all members have locked their memberships
  #
  # @return [Boolean] true if the group can be locked
  def lockable?
    (members - locked_members).empty? && members_count == size
  end

  private

  # override default attribute getter to include transfers
  def members_count
    return 0 unless memberships_count || transfers
    return memberships_count unless transfers
    return transfers unless memberships_count
    memberships_count + transfers
  end

  def add_leader_to_members
    members << leader unless members.include? leader
  end

  def validate_suite_size_inclusion
    # TODO: if we start seeing this pattern (draw.present? branching logic) more
    # often then we can extract special group functionality into a subclass that
    # still talks to the same table in the db to keep things clean.
    if draw.present?
      return if draw.open_suite_sizes.include? size
      errors.add :size, 'must be a suite size included in the draw'
    else
      return if SuiteSizesQuery.call.include? size
      errors.add :size, 'must be a valid suite size'
    end
  end

  def validate_members_count
    return unless members_count > size
    errors.add :members, "can't be greater than the size (#{size})"
  end

  def validate_status
    return unless status_changed?
    case status
    when 'open'
      validate_open
    when 'locked'
      validate_locked
    else
      validate_not_open
    end
  end

  def validate_open
    return unless members_count >= size
    errors.add :status, 'can only be open when fewer members than size'
  end

  def validate_not_open
    return unless members_count != size
    errors.add :status, "can only be #{status} when members equal size"
  end

  def restore_member_draws
    members.each { |u| u.restore_draw.save }
  end

  def validate_locked
    validate_not_open
    return if lockable?
    errors.add :status, 'can only be locked when all members have locked'
  end
end
