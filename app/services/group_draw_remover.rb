# frozen_string_literal: true
#
# Service object to handle the conversion of a regular group to a drawless
# group. It handles the removal of the draw from all group members and destroys
# all pending invitations and requests.
class GroupDrawRemover
  # permits the calling of :remove on the class
  def self.remove(**params)
    new(**params).remove
  end

  # Initializes a new GroupDrawRemover
  #
  # @param group [Group] the group in question
  def initialize(group:)
    @group = group
    @members = group.members
    @pending = group.pending_memberships
  end

  # Removes the draw_id from the group and makes other necessary changes
  #
  # @return [Hash{Symbol=>Group,Hash,Array}] the results hash
  def remove
    ActiveRecord::Base.transaction do
      group.update!(draw_id: nil)
      members.each { |s| s.remove_draw.update!(intent: 'on_campus') }
      pending.each(&:destroy!)
    end
    success
  rescue ActiveRecord::ActiveRecordError => e
    error(e)
  end

  private

  attr_reader :group, :members, :pending

  def success
    {
      object: group,
      msg: { success: "#{group.name} is now a special group" }
    }
  end

  def error(errors)
    {
      object: [group.draw, group],
      msg: { error: "Error converting group to a special group: #{errors}" }
    }
  end
end
