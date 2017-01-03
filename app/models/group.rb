# frozen_string_literal: true
#
# Model for Housing Groups
#
# @attr size [Integer] The room size that the Group wants.
# @attr status [String] The state of the group (open, full, or locked)
# @attr leader [User] The student that represents the Group.
# @attr members [Array<User>] The members of the group, excluding the leader.
# @attr draw [Draw] The Draw that this Group is in.
class Group < ApplicationRecord
  belongs_to :leader, class_name: 'User'
  belongs_to :draw
  has_many :memberships
  has_many :members, through: :memberships, source: :user

  enum status: %w(open full locked)

  validates :draw, presence: true
  validates :status, presence: true
  validates :size, presence: true,
                   inclusion: { in: ->(g) { g.draw.suite_sizes },
                                if: ->(g) { g.draw.present? } }
  validates :leader, presence: true, inclusion: { in: ->(g) { g.members } }

  validate :validate_members_count, if: ->(g) { g.size.present? }
  validate :validate_status, if: ->(g) { g.size.present? }

  before_validation :add_leader_to_members, if: ->(g) { g.leader.present? }

  def name
    "#{leader.name}'s Group"
  end

  # Updates the status to match the group size (open when fewer members than
  # the size, and full when they are the same)
  def update_status
    if memberships_count < size
      update(status: 'open')
    elsif memberships_count == size
      update(status: 'full')
    end
  end

  private

  def add_leader_to_members
    members << leader unless members.include? leader
  end

  def validate_members_count
    return unless memberships_count > size
    errors.add :members, "can't be greater than the size (#{size})"
  end

  def validate_status
    return unless status_changed?
    case status
    when 'open'
      validate_open
    else
      validate_full_locked
    end
  end

  def validate_open
    return unless memberships_count >= size
    errors.add :status, 'can only be open when fewer members than size'
  end

  def validate_full_locked
    return unless memberships_count != size
    errors.add :status, "can only be #{status} when members equal size"
  end
end
