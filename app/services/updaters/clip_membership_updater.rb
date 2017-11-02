# frozen_string_literal: true

#
# Service object to update clip memberships
class ClipMembershipUpdater < Updater
  # Initialize a ClipMembershipUpdater
  #
  # @param clip_membership [ClipMembership] clip membership object to be updated
  # @param params [#to_h] new attributes
  def initialize(clip_membership:, params:)
    super(object: clip_membership, name_method: nil, params: params)
  end

  private

  # This success message assumes that the only update to a clip membership
  # is from unconfirmed -> confirmed
  def success
    { redirect_object: [object.group.draw, object.group],
      msg: { success: "#{object.group.name} joined #{object.clip.name}." } }
  end
end
