# frozen_string_literal: true

#
# Service object to remove the suite from a given group.
class SuiteRemover
  include Callable

  # Initialize a new SuiteRemover
  #
  # @param group [Group] the group to remove the suite from
  def initialize(group:)
    @group = group
    @suite = group.suite if group
    @errors = []
  end

  # Remove a suite from a group. Checks to make sure that the group currently
  # has a suite assigned.
  #
  # @return [Hash{symbol=>Group,Hash}] a results hash with a message to set in
  #   the flash, nil or the group as the :redirect_object,
  #   and an action to render.
  def remove
    if remove_suite_from_group
      success
    else
      error
    end
  end

  make_callable :remove

  private

  attr_accessor :errors
  attr_reader :group, :suite

  def valid?
    errors << 'Group has no suite assigned.' if group_has_no_suite?
    errors.empty?
  end

  def group_has_no_suite?
    suite.nil?
  end

  def remove_suite_from_group
    return false unless valid?
    return true if suite.update(group: nil)
    errors << suite.errors.full_messages.join("\n")
    false
  end

  def success
    {
      redirect_object: group,
      msg: { success: "Suite removed from #{group.name}" }
    }
  end

  def error
    {
      redirect_object: nil,
      msg: { error: "Oops, there was a problem:\n#{errors.join("\n")}" }
    }
  end
end
