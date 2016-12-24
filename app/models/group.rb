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
  has_many :members, class_name: 'User'

  validates :size, presence: true, numericality: { only_integer: true,
                                                   greater_than: 0 }
  validates :status, presence: true
  validates :leader, presence: true
  validates :draw, presence: true

  enum status: %w(open full locked)

  after_save :add_leader_to_members

  def name
    "#{leader.name}'s Group"
  end

  private

  def add_leader_to_members
    members.append(leader) unless members.include? leader
  end
end
