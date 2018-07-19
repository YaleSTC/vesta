# frozen_string_literal: true

#
# Service object to update memberships
class MembershipUpdater < Updater
  validate :params_are_correct

  # Initialize a MembershipUpdater
  #
  # @param membership [Membership] The membership object to be updated
  # @param action [String] The action to do (either 'accept' or 'finalize')
  def initialize(membership:, action:)
    process_params(action)
    super(object: membership, name_method: nil, params: params)
  end

  private

  def success
    send_joined_email if user_has_accepted?
    { redirect_object: [object.group.draw, object.group],
      msg: { success: "#{object.user.full_name} joined group "\
             "#{object.group.name}." } }
  end

  def process_params(action)
    @params = if action == 'accept'
                { status: 'accepted' }
              elsif action == 'finalize'
                { locked: true }
              end
  end

  def params_are_correct
    return if params.present?
    errors.add(:base, 'Memberships can only be accepted or finalized.')
  end

  def send_joined_email
    # leaders are the ones who accept requests so we don't need to e-mail them
    return if object.status_before_last_save == 'requested'
    StudentMailer.joined_group(joined: object.user, group: object.group,
                               college: College.current).deliver_later
  end

  def user_has_accepted?
    object.saved_change_to_status && object.accepted?
  end
end
