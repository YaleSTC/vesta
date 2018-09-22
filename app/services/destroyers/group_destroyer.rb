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
    return error unless remove_member_rooms
    if object.destroy
      object.members.each do |m|
        StudentMailer.disband_notification(user: m).deliver_later
      end
      restore_member_draws
      success
    else
      error
    end
  end

  private

  def remove_member_rooms
    ActiveRecord::Base.transaction do
      object.members.each do |member|
        member.room_assignment.destroy! if member.room_assignment.present?
      end
      true
    end
  rescue
    false
  end

  def restore_member_draws
    return unless object.draw.nil?
    object.members.each { |u| u.restore_draw.save }
  end
end
