# frozen_string_literal: true

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
# @attr lottery_assignment [LotteryAssignment] the lottery assignment for the
#   group
# @attr clip [Clip] The clip that the group is in, if any.
# @attr clip_memberships [Array<ClipMembership>] All clip memberships that the
#   group is associated with, pending or confirmed.
# @attr clip_membership [ClipMembership] The confirmed clip membership for the
#   group, if any.
class Group < ApplicationRecord # rubocop:disable ClassLength
  belongs_to :leader_draw_membership, class_name: 'DrawMembership',
                                      inverse_of: :led_group
  has_one :leader, through: :leader_draw_membership, class_name: 'User',
                   source: :user
  belongs_to :draw
  has_one :clip_membership, -> { where(confirmed: true) }, dependent: :destroy
  has_one :clip, through: :clip_membership
  has_many :clip_memberships, dependent: :destroy
  has_one :suite_assignment, dependent: :destroy
  has_one :suite, through: :suite_assignment
  belongs_to :lottery_assignment
  accepts_nested_attributes_for :suite

  has_many :memberships, dependent: :delete_all
  has_many :full_memberships, -> { where(status: 'accepted') },
           class_name: 'Membership', inverse_of: :group
  has_many :draw_memberships, through: :full_memberships,
                              source: :draw_membership
  has_many :members, through: :draw_memberships, source: :user

  delegate :number, to: :lottery_assignment, prefix: :lottery, allow_nil: true
  delegate :number, to: :suite, prefix: :suite, allow_nil: true
  delegate :building_name, to: :suite, allow_nil: true
  delegate :id, to: :leader, prefix: :leader, allow_nil: true

  enum status: %w(open closed finalizing locked)

  validates :status, presence: true
  validates :leader, presence: true
  validates :size, presence: true,
                   numericality: { greater_than: 0 }
  validates :leader_draw_membership, presence: true,
                                     inclusion:
                                     { in: ->(g) { g.draw_memberships } }
  validates :memberships_count, numericality: { greater_than_or_equal_to: 0 }
  validates :transfers, presence: true,
                        numericality: { greater_than_or_equal_to: 0,
                                        only_integer: true }
  validate :validate_members_count, if: ->(g) { g.size.present? }
  validate :validate_status, if: ->(g) { g.size.present? }
  validate :validate_lottery_assignment,
           if: -> { will_save_change_to_lottery_assignment_id? }

  before_validation :add_leader_to_members,
                    if: ->(g) { g.leader_draw_membership.present? }
  after_save :update_status!,
             if: ->() { saved_change_to_transfers || saved_change_to_size }
  before_update :freeze_lottery,
                if: -> { will_save_change_to_lottery_assignment_id? }
  after_update :remove_clip_memberships,
               if: ->() { changed_draw_with_clip_memberships? }

  after_destroy :destroy_lottery_assignment,
                if: ->(g) { g.lottery_assignment.present? }

  attr_reader :remove_ids

  scope :order_by_lottery,
        -> { joins(:lottery_assignment).order('lottery_assignments.number') }

  scope :active, lambda {
    includes(:leader_draw_membership).where(draw_memberships: { active: true })
  }

  # Generate the group name
  #
  # @return [String] the group's name
  def name(*opts)
    base = "#{leader.full_name}'s Group"
    opt_strs = opts.map { |o| name_str(o) }.compact.join(', ')
    return base unless opt_strs.present?
    "#{base} (#{opt_strs})"
  end

  # Updates the status to match the group size (open when fewer members than
  # the size, and full when they are the same). Uses `update_columns` to avoid a
  # SystemStackError under certain circumstances (skips callbacks).
  def update_status!
    assign_new_status
    return unless status && valid?
    update_columns(status: status) # rubocop:disable Rails/SkipsModelValidations
  end

  # Get the group's membership requests
  #
  # @return [Array<Membership>] the group's memberships with a requested status
  def requests
    memberships.select { |m| m.status == 'requested' }
  end

  # Get the group's membership invitations
  #
  # @return [Array<Membership>] the group's memberships with an invited status
  def invitations
    memberships.select { |m| m.status == 'invited' }
  end

  # Get all of the non-accepted memberships for the group
  #
  # @return [Array<Membership>] the memberships that are not accepted
  def pending_memberships
    memberships.where.not(status: 'accepted')
  end

  # Get the group's members that can be removed
  #
  # @return [Array<User>] the members of the group with the exception of the
  #   group leader
  def removable_members
    members.joins(:draw_membership).where
           .not(draw_memberships: { id: leader_draw_membership_id })
  end

  # Remove specified members
  #
  # @param ids [Array<User>] members of the group
  # @return [Array<User>] the remaining members of the group after deletion
  def remove_members!(ids:)
    ids.delete_if { |u| u == leader.id }
    memberships.joins(:draw_membership)
               .where(draw_memberships: { user_id: ids }).delete_all
    # rubocop:disable Rails/SkipsModelValidations
    decrement!(:memberships_count, ids.size)
    # rubocop:enable Rails/SkipsModelValidations
    update_status!
  end

  # Get the group's locked/finalized members
  #
  # @return [Array<User>] the users who have locked their membership
  def locked_members
    full_memberships.where(locked: true).includes(:user).map(&:user)
  end

  # Check if all members have locked their memberships
  #
  # @return [Boolean] true if the group can be locked
  def lockable?
    (members - locked_members).empty? && members_count == size
  end

  # Check if there are any locked memberships
  #
  # @return [Boolean] true if there are any unlocked members
  def unlockable?
    !locked_members.empty? && suite.nil?
  end

  # Check if the group is full
  #
  # @return [Boolean] true if the group's size equals the number of members
  #   in it
  def full?
    members_count == size
  end

  # Return the lottery number assigned to the group, if present
  #
  # @return [Integer, nil] the number, or nil if it isn't present
  def lottery_number
    return nil unless lottery_assignment
    lottery_assignment.number
  end

  # Check if there is an open invitation to join the provided clip
  #
  # @param [Clip] the clip to check for its invitation status
  # @return [Boolean] true if invited to join the given clip
  def invited_to_clip?(clip)
    clip_memberships.where(clip_id: clip.id, confirmed: false).present?
  end

  # Destroys the group if it contains no members. It is called
  # automatically after a membership in the group is destroyed.
  #
  # @return [Group] the group destroyed or nil if no change
  def cleanup!
    destroy! if existing_memberships.length <= 0
  end

  # For use with simple_form_for's label_method
  #
  # @return [String] the group's name with the size appended
  def to_label
    name(:with_size)
  end

  private

  def name_str(opt)
    case opt
    when :with_size
      Suite.size_str(size)
    when :with_year
      leader.class_year.to_s
    end
  end

  def remove_clip_memberships
    clip_memberships.each(&:destroy)
  end

  # override default attribute getter to include transfers
  def members_count
    return 0 unless memberships_count || transfers
    return memberships_count unless transfers
    return transfers unless memberships_count
    memberships_count + transfers
  end

  def add_leader_to_members
    return if draw_memberships.include?(leader_draw_membership)
    draw_memberships << leader_draw_membership
  end

  def validate_members_count
    return unless members_count > size
    errors.add :members, "can't be greater than the size (#{size})"
  end

  def validate_status
    return unless will_save_change_to_status?
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
    return if full?
    errors.add :status, "can only be #{status} when members equal size"
  end

  def validate_locked
    validate_not_open
    return if lockable?
    errors.add :status, 'can only be locked when all members have locked'
  end

  def validate_lottery_assignment
    return unless lottery_assignment.present?
    if clip.present?
      validate_lottery_for_clipped
    else
      validate_lottery_for_unclipped
    end
  end

  def validate_lottery_for_clipped
    return if clip == lottery_assignment.clip
    errors.add(:lottery_assignment, 'must belong to the same clip')
  end

  def validate_lottery_for_unclipped
    return if clip.present?
    return if lottery_assignment.groups.length == 1 &&
              lottery_assignment.group == self
    errors.add(:lottery_assignment, 'can only have one group unless clipped')
  end

  def freeze_lottery
    if lottery_assignment_id_in_database.present? &&
       lottery_assignment_id.present?
      handle_abort('Cannot edit lottery assignment once set')
    end
  end

  def changed_draw_with_clip_memberships?
    saved_change_to_draw_id && clip_memberships.present?
  end

  def assign_new_status
    if members_count < size
      self.status = 'open'
    elsif full?
      self.status = 'closed' unless finalizing? || lockable?
      self.status = 'locked' if lockable?
    end
  end

  def destroy_lottery_assignment
    lottery_assignment.process_group_destruction!
  end

  def existing_memberships
    memberships.to_a.keep_if(&:persisted?)
  end
end
