# frozen_string_literal: true

#
# Class to destroy memberships
class MembershipDestroyer < Destroyer
  # Initialize a new MembershipsDestroyer.
  #
  # @param [ApplicationRecord] object The model object to be destroyed
  def initialize(membership:)
    @object = membership
    @name = "#{membership.user.full_name}'s membership"
  end

  private

  def success
    { redirect_object: nil, msg: { notice: "#{name} deleted." } }
  end

  def error
    { redirect_object: nil, msg: { error: "#{name} couldn't be deleted." } }
  end
end
