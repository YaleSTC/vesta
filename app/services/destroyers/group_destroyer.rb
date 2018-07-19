# frozen_string_literal: true

#
# Class to destroy groups
class GroupDestroyer < Destroyer
  # Initialize a new Destroyer.
  #
  # @param [ApplicationRecord] object The model object to be destroyed
  def initialize(group:)
    @object = group
    @name = group.name
    @klass = group.class
  end

  # Attempt to destroy a group.
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}]
  #   A results hash with a message to set in the flash and either `nil`
  #   or the group that was not destroyed
  def destroy
    if object.destroy
      object.members.each do |m|
        StudentMailer.disband_notification(user: m).deliver_later
      end
      success
    else
      error
    end
  end
end
