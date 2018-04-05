# frozen_string_literal: true

#
# Service object to handle the conversion of a regular group to a drawless
# group. It handles the removal of the draw from all group members and destroys
# all pending invitations and requests.
class GroupDrawRemover
  include Callable

  # Initializes a new GroupDrawRemover
  #
  # @param group [Group] the group in question
  def initialize(group:)
    @group = group
    @members = group.members
    @pending = group.pending_memberships
    @clip_membership = group.clip_membership
    @lottery = group.lottery_assignment
  end

  # Removes the draw_id from the group and makes other necessary changes
  #
  # @return [Hash{Symbol=>Group,Hash,Array}] the results hash
  def remove
    ActiveRecord::Base.transaction do
      handle_clip_membership
      handle_lottery_assignment
      group.update!(draw_id: nil)
      members.each { |s| s.remove_draw.update!(intent: 'on_campus') }
      pending.each(&:destroy!)
    end
    success
  rescue ActiveRecord::ActiveRecordError => e
    error(e)
  end

  make_callable :remove

  private

  attr_reader :group, :members, :pending, :clip_membership, :lottery

  def handle_clip_membership
    return unless clip_membership.present?
    clip_membership.destroy!
  end

  def handle_lottery_assignment
    return unless lottery.present?
    if lottery.groups.count == 1
      lottery.destroy!
    else
      group.update!(lottery_assignment_id: nil)
    end
  end

  def success
    {
      redirect_object: group,
      msg: { success: "#{group.name} is now a special group" }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      redirect_object: [group.draw, group], record: group,
      msg: { error: "Error converting group to a special group: #{msg}" }
    }
  end
end
