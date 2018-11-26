# frozen_string_literal: true

#
# Service object to remove the suite from a given group.
class SuiteAssignmentDestroyer < Destroyer
  # Validate if the suite_assignment exists on `valid?`
  validates :object, presence: true

  # Initialize a new SuiteDestroyer
  #
  # @param group [Group] the group to remove the suite from
  def initialize(group:)
    @group = group
    @object = group.suite_assignment
    @name = group.name
  end

  private

  def success
    {
      redirect_object: @group,
      msg: { success: "Suite removed from #{name}" }
    }
  end

  def error
    { redirect_object: nil,
      msg: { error: "Suite assignment for #{name} couldn't be deleted." } }
  end
end
