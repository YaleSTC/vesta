# frozen_string_literal: true
#
# Service object to finalize groups
class GroupFinalizer
  # Initialize a new GroupFinalizer and call #finalize on it
  def self.finalize(**params)
    new(**params).finalize
  end

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
    return error unless valid?
    ActiveRecord::Base.transaction do
      group.finalizing!
      unless group.leader.membership.locked
        group.leader.membership.update!(locked: true)
      end
    end
    success
  rescue ActiveRecord::RecordInvalid => failures
    @errors = failures
    error
  end

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

  def error
    { object: [group.draw, group], record: group,
      msg: { error: errors.join(', ') } }
  end

  def success
    { object: [group.draw, group], record: group,
      msg: { success: "#{group.name} is being finalized." } }
  end
end
