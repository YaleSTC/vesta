# frozen_string_literal: true

#
# Service object to destroy clip memberships
class ClipMembershipDestroyer < Destroyer
  # Initialize a ClipMembershipsDestroyer.
  #
  # @param clip_membership [ClipMembership] the object to be destroyed
  def initialize(clip_membership:)
    @object = clip_membership
    @msg = if clip_membership.confirmed
             'Successfully left clip.'
           else
             'Successfully rejected invitation.'
           end
  end

  private

  attr_reader :msg

  def success
    { redirect_object: nil, msg: { notice: msg } }
  end

  def error
    { redirect_object: [obj.clip.draw, obj.clip],
      msg: { error: "Couldn't leave clip." } }
  end
end
