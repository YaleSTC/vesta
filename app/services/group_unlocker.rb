# frozen_string_literal: true

# Service object to unlock groups
class GroupUnlocker
  include Callable

  # Initialize a GroupLocker
  #
  # @param group [Group] The group object to be updated
  def initialize(group:)
    @group = group
    @locked_memberships = group.full_memberships.where(locked: true)
  end

  # Unlock a group by unlocking each membership
  #
  # @return [Hash{Symbol=>Array, Group, Hash}] The result of the finalizing
  def unlock
    # TODO: implement ActiveModel::Model, make this a validation
    return error(CANNOT_BE_UNLOCKED_MSG) unless group.unlockable?
    ActiveRecord::Base.transaction do
      locked_memberships.each { |m| m.update!(locked: false) }
      update_group_status(group)
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(ErrorHandler.format(error_object: e))
  end

  make_callable :unlock

  private

  CANNOT_BE_UNLOCKED_MSG = 'Group has no locked memberships'

  attr_reader :group, :locked_memberships

  # Note that this occurs in the transaction
  def update_group_status(group)
    group.status = 'full' if group.finalizing?
    group.update_status!
  end

  def success
    { redirect_object: [group.draw, group], record: group,
      msg: { success: "#{group.name} is unlocked." } }
  end

  def error(msg)
    { redirect_object: [group.draw, group], record: group,
      msg: { error: "Error: #{msg}" } }
  end
end
