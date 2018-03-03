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
end
