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
    membership = group.memberships.find_by(user_id: member.id)
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
end
