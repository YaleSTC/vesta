# frozen_string_literal: true

#
# Service object to lock groups
class GroupLocker
  # Initialize a new GroupLocker and call #lock on it
  def self.lock(**params)
    new(**params).lock
  end

  # Initialize a GroupLocker
  #
  # @param group [Group] The group object to be updated
  def initialize(group:)
    @group = group
  end

  # Lock a group by locking each membership
  #
  # @return [Hash{Symbol=>Array, Group, Hash}] The result of the finalizing
  def lock
    ActiveRecord::Base.transaction do
      group.update!(status: 'finalizing')
      group.full_memberships.reject(&:locked).each do |m|
        m.update!(locked: true)
      end
    end
    success
  rescue ActiveRecord::RecordInvalid => errors
    error(errors.record.errors.full_messages)
  end

  private

  attr_reader :group

  def error(errors)
    { redirect_object: [group.draw, group], record: group,
      msg: { error: errors.join(', ') } }
  end

  def success
    { redirect_object: [group.draw, group], record: group,
      msg: { success: "#{group.name} is locked." } }
  end
end
