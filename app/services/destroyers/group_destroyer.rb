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
    ActiveRecord::Base.transaction do
      remove_member_rooms
      object.destroy!
      restore_member_draws
      email_members_of_disband
    end
    success
  rescue ActiveRecord::ActiveRecordError
    error
  end

  private

  def remove_member_rooms
    object.members.each do |member|
      member.room_assignment.destroy! if member.room_assignment.present?
    end
  end

  def email_members_of_disband
    object.members.each do |m|
      StudentMailer.disband_notification(user: m).deliver_later
    end
  end

  def restore_member_draws
    return unless object.draw.nil?
    object.members.each { |u| u.restore_draw.save! }
  end
end
