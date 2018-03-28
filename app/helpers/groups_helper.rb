# frozen_string_literal: true

# Helper methods for the Groups views
module GroupsHelper
  # Generate the user listing for a group member; includes membership lock
  # status
  #
  # @param member [User] the user
  # @param group [Group] the user's group
  # @return [String] the user listing
  def member_str(member, group)
    membership = member.membership
    locked_str = membership.locked? ? ' (locked)' : ''
    leader_str = group.leader == member ? ' (leader)' : ''
    link_to(member.full_name, user_path(member)) + leader_str + locked_str
  end

  # Sort an array of groups by lottery number (nil first), then by group leader
  # last name
  #
  # @param groups [Array<Group>] the groups to sort
  # @return [Array<Group>] the sorted groups
  def sort_by_lottery(groups)
    groups.sort_by do |g|
      if g.lottery_number.nil?
        [-Float::INFINITY, g.leader.last_name]
      else
        [g.lottery_number, g.leader.last_name]
      end
    end
  end

  # Displays the status of a group as the capitalization of its current
  # status. In the case of 'closed' it returns Full to maintain the
  # readability.
  #
  # @param [String] the group that's status will be displayed
  # @return [String] the capitalization of the current status
  def display_group_status(group)
    if group.closed?
      'Full'
    elsif group.finalizing?
      'Locking'
    else
      group.status.capitalize
    end
  end

  # Generate the group name with relevant clipping information appended
  #
  # @param [Group] the group needing the appended information
  # @return [String] the group's name
  def clipping_name(group)
    group.name + if group.clip.present?
                   ' (confirmed)'
                 elsif group.clip_memberships.present? && group.clip.blank?
                   ' (invited to clip)'
                 else
                   ''
                 end
  end
end
