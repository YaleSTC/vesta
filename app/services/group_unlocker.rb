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
    return error('Group has no locked memberships') unless group.unlockable?
    ActiveRecord::Base.transaction do
      locked_memberships.each { |m| m.update!(locked: false) }
      update_group_status(group)
    end
    success
  rescue ActiveRecord::RecordInvalid => errors
    error(error_messages(errors))
  end

  make_callable :unlock

  private

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

  def error(errors)
    { redirect_object: [group.draw, group], record: group,
      msg: { error: errors } }
  end

  def error_messages(errors)
    errors.record.errors.full_messages.join(', ')
  end
end
