# frozen_string_literal: true

#
# Service object to finalize groups
class GroupFinalizer
  include Callable

  # Initialize a GroupFinalizer
  #
  # @param group [Group] The group object to be updated
  def initialize(group:)
    @group = group
    @errors = []
  end

  # Finalize a group
  #
  # @return [Hash{Symbol=>Array, Group, Hash}] The result of the finalizing
  def finalize # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return error(errors.join(', ')) unless valid?
    ActiveRecord::Base.transaction do
      group.finalizing!
      unless group.leader.membership.locked
        group.leader.membership.update!(locked: true)
      end
    end
    notify_members
    success
  rescue ActiveRecord::RecordInvalid => e
    # TODO: include ActiveModel::Model here, make the error handling consistent
    error(ErrorHandler.format(error_object: e))
  end

  make_callable :finalize

  private

  attr_accessor :errors
  attr_reader :group

  def valid?
    group_full?
    suite_size_open?
    errors.empty?
  end

  def group_full?
    return if group.full?
    @errors << 'Group must be full'
  end

  def suite_size_open?
    return if group.draw.open_suite_sizes.include? group.size
    @errors << 'Suite size must be open'
  end

  def error(msg)
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
