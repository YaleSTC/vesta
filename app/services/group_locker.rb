# frozen_string_literal: true

#
# Service object to lock groups
class GroupLocker
  include Callable

  # Initialize a GroupLocker
  #
  # @param group [Group] The group object to be updated
  def initialize(group:)
    @group = group
  end

  # Lock a group by locking each membership
  # Email both leader and group members
  #
  # @return [Hash{Symbol=>Array, Group, Hash}] The result of the finalizing
  def lock
    ActiveRecord::Base.transaction do
      group.update!(status: 'finalizing')
      group.full_memberships.reject(&:locked).each do |m|
        lock_and_email(m)
      end
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :lock

  private

  attr_reader :group

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: [group.draw, group], record: group,
      msg: { error: "Error: #{msg}" } }
  end

  def success
    { redirect_object: [group.draw, group], record: group,
      msg: { success: "#{group.name} is locked." } }
  end

  def lock_and_email(member)
    member.update!(locked: true)
    StudentMailer.group_locked(user: member.user).deliver_later
  end
end
