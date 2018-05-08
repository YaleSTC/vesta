# frozen_string_literal: true

#
# Class to destroy memberships
class MembershipDestroyer < Destroyer
  validate :membership_is_not_locked

  # Initialize a new MembershipsDestroyer.
  #
  # @param [ApplicationRecord] object The model object to be destroyed
  def initialize(membership:)
    @object = membership
    @name = "#{membership.user.full_name}'s membership"
  end

  private

  def success
    send_left_email if object.status == 'accepted'
    { redirect_object: nil, msg: { notice: "#{name} deleted." } }
  end

  def error
    msg = if errors.present?
            ErrorHandler.format(error_object: self)
          else
            "#{name} couldn't be deleted."
          end
    { redirect_object: nil, msg: { error: msg } }
  end

  def membership_is_not_locked
    return unless object.locked?
    errors.add(:base, "#{name} cannot be destroyed if it is locked.")
  end

  def send_left_email
    StudentMailer.left_group(left: object.user, group: object.group,
                             college: College.current).deliver_later
  end
end
