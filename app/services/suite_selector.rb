# frozen_string_literal: true
#
# Service object to select suites for a given group.
class SuiteSelector
  attr_reader :errors

  # Allow for :select to be called on the parent class
  def self.select(**params)
    new(**params).select
  end

  # Initialize a new SuiteSelector
  #
  # @param group [Group] the group to assign the suite to
  # @param suite_id [Integer] the suite id to assign to the group
  def initialize(group:, suite_id:)
    @group = group
    @suite_id = suite_id
    @errors = []
  end

  # Select / assign a suite to a group. Checks to make sure that the group does
  # not curretly have a suite assigned, that the suite_id corresponds to an
  # existing suite, and that the suite is not currently assigned to a different
  # group.
  #
  # @return [Hash{symbol=>Group,Hash}] a results hash with a message to set in
  #   the flash, nil or the group as the :object, and an action to render.
  def select
    if assign_suite_to_group
      success
    else
      error
    end
  end

  private

  attr_writer :errors
  attr_reader :group, :suite_id, :suite

  def valid?
    if group_already_has_suite
      errors << 'Group already has a suite assigned.'
    elsif suite_id_missing
      errors << 'You must pass a suite id.'
    elsif suite_does_not_exist
      errors << 'Suite does not exist.'
    elsif suite_already_assigned
      errors << 'Suite is assigned to a different group'
    end
    errors.empty?
  end

  def group_already_has_suite
    group.suite.present?
  end

  def suite_id_missing
    suite_id.nil?
  end

  def suite_does_not_exist
    return unless suite_id.present?
    @suite ||= Suite.find_by(id: suite_id.to_i)
    suite.nil?
  end

  def suite_already_assigned
    return unless suite
    suite.group_id.present?
  end

  def assign_suite_to_group
    return false unless valid?
    return true if suite.update(group: group)
    errors << suite.errors.full_messages.join("\n")
    false
  end

  def success
    {
      object: group,
      msg: { success: "Suite #{suite.number} assigned to #{group.name}" }
    }
  end

  def error
    {
      object: nil,
      msg: { error: "Oops, there was a problem:\n#{errors.join("\n")}" }
    }
  end
end
