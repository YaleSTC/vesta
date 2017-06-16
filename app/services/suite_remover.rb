# frozen_string_literal: true

#
# Service object to remove the suite from a given group.
class SuiteRemover
  include ActiveModel::Model
  include Callable

  # Validate if the suite exists on `valid?`
  # Returns message if it doesn't exist
  validates :suite, presence: { message: 'Group has no suite assigned.' }

  # Initialize a new SuiteRemover
  #
  # @param group [Group] the group to remove the suite from
  def initialize(group:)
    @group = group
    @suite = group.suite if group
  end

  # Remove a suite from a group. Checks to make sure that the group currently
  # has a suite assigned.
  #
  # @return [Hash{symbol=>Group,Hash}] a results hash with a message to set in
  #   the flash, nil or the group as the :redirect_object,
  #   and an action to render.
  def remove
    return error(self) unless valid?
    suite.update!(group: nil)
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :remove

  private

  attr_reader :group, :suite

  def remove_suite_from_group
    return error(self) unless valid?
    suite.update!(group: nil)
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  def success
    {
      redirect_object: group,
      msg: { success: "Suite removed from #{group.name}" }
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
