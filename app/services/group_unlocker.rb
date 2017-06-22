# frozen_string_literal: true

# Service object to unlock groups
class GroupUnlocker
  include ActiveModel::Model
  include Callable

  validate :unlockable_group

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
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      locked_memberships.each { |m| m.update!(locked: false) }
      update_group_status(group)
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :unlock

  private

  attr_reader :group, :locked_memberships

  # Note that this occurs in the transaction
  def update_group_status(group)
    group.status = 'closed' if group.full?
    group.update_status!
  end

  def unlockable_group
    errors.add(:group, 'has no locked memberships') unless group.unlockable?
  end

  def success
    { redirect_object: [group.draw, group], record: group,
      msg: { success: "#{group.name} is unlocked." } }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: [group.draw, group], record: group,
      msg: { error: "Error: #{msg}" } }
  end
end
