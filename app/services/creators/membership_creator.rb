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
    set_params(user, group, action)
    super(klass: Membership, name_method: nil, params: params)
  end

  private

  def success
    { redirect_object: [obj.group.draw, obj.group], membership: obj,
      msg: { success: "Membership in #{obj.group.name} created for "\
        "#{obj.user.name}." } }
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

  def set_params(user, group, action)
    status = if action == 'request'
               'requested'
             elsif action == 'invite'
               'invited'
             end
    @params = { user: user, group: group, status: status }
  end
end
