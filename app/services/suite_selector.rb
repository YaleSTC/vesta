# frozen_string_literal: true

#
# Service object to select suites for a given group.
class SuiteSelector
  include Callable
  include ActiveModel::Model

  validate :group_does_not_have_a_suite
  validate :suite_id_present
  validate :suite_exists
  validate :group_locked
  validate :suite_not_already_assigned

  # Initialize a new SuiteSelector
  #
  # @param group [Group] the group to assign the suite to
  # @param suite_id [Integer] the suite id to assign to the group
  def initialize(group:, suite_id:)
    @group = group
    @suite_id = suite_id
  end

  # Select / assign a suite to a group. Checks to make sure that the group does
  # not curretly have a suite assigned, that the suite_id corresponds to an
  # existing suite, and that the suite is not currently assigned to a different
  # group.
  #
  # @return [Hash{symbol=>Group,Hash}] a results hash with a message to set in
  #   the flash, nil or the group as the :redirect_object,
  #   and an action to render.
  def select
    return error(self) unless valid?
    suite.update!(group: group)
    assign_single! if suite.size == 1
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :select

  private

  attr_reader :group, :suite_id, :suite

  def group_does_not_have_a_suite
    errors.add(:group, 'already has a suite assigned.') if group.suite.present?
  end

  def suite_id_present
    errors.add(:base, 'You must pass a suite id.') if suite_id.nil?
  end

  def suite_exists
    return unless suite_id.present?
    @suite ||= Suite.find_by(id: suite_id.to_i)
    errors.add(:suite, 'does not exist.') if suite.nil?
  end

  def group_locked
    errors.add(:group, 'must be locked.') unless group.locked?
  end

  def suite_not_already_assigned
    return unless suite
    return unless suite.group_id.present?
    errors.add(:suite, 'is assigned to a different group')
  end

  def assign_single!
    room = suite.rooms.where(beds: 1).first
    RoomAssignment.create!(user: group.leader, room: room)
  end

  def success
    {
      redirect_object: group,
      msg: { success: "Suite #{suite.number} assigned to #{group.name}" }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      redirect_object: nil,
      msg: { error: "Oops, there was a problem: #{msg}" }
    }
  end
end
