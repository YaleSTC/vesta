# frozen_string_literal: true
#
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
    member.full_name + locked_str
  end
end
