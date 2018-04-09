# frozen_string_literal: true

#
# Service object to finalize groups
class GroupFinalizer
  include ActiveModel::Model
  include Callable

  validate :group_full

  # Initialize a GroupFinalizer
  #
  # @param group [Group] The group object to be updated
  def initialize(group:)
    @group = group
  end

  # Finalize a group
  #
  # @return [Hash{Symbol=>Array, Group, Hash}] The result of the finalizing
  def finalize # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      group.finalizing!
      unless group.leader.membership.locked
        group.leader.membership.update!(locked: true)
      end
    end
    notify_members
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :finalize

  private

  attr_reader :group

  def group_full
    errors.add(:group, 'must be full') unless group.full?
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: [group.draw, group], record: group,
      msg: { error: "Error: #{msg}" } }
  end

  def success
    { redirect_object: [group.draw, group], record: group,
      msg: { success: "#{group.name} is being finalized." } }
  end

  def notify_members
    members = group.members - [group.leader]
    members.each do |m|
      StudentMailer.finalizing_notification(user: m).deliver_later
    end
  end
end
