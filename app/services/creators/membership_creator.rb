# frozen_string_literal: true

#
# Service object to create memberships.
class MembershipCreator < Creator
  # Initialize a MembershipCreator
  #
  # @param [User] user The user to create the membership for
  # @param [Group] group The group to create the membership in
  # @param [String] action The action creating the membership (ie. 'request')
  def initialize(user:, group:, action:)
    @klass = Membership
    @user = user
    @draw_membership = user&.draw_membership
    @group = group
    process_params(action)
  end

  private

  attr_reader :user, :draw_membership, :group, :status

  def success
    send_create_email unless status == 'accepted'
    { redirect_object: [group.draw, group], membership: obj,
      msg: { success: "Membership in #{group.name} created for "\
        "#{user.name}." } }
  end

  def error(e)
    msg = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil, membership: obj,
      msg: { error: "Please review the errors below:\n#{msg}" },
      errors: msg,
      params: params
    }
  end

  def process_params(action)
    @status = if action == 'request'
                'requested'
              elsif action == 'invite'
                'invited'
              end
    @params = { draw_membership: draw_membership, group: group, status: status }
  end

  def send_create_email
    return if user.leader_of?(group)
    mailer_method = "#{status}_to_join_group"
    StudentMailer.send(mailer_method, status.to_sym => user,
                                      group: group).deliver_later
  end
end
