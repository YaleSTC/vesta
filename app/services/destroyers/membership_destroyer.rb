# frozen_string_literal: true
#
# Class to destroy memberships
class MembershipDestroyer < Destroyer
  # Initialize a new MembershipsDestroyer.
  #
  # @param [ApplicationRecord] object The model object to be destroyed
  def initialize(membership:)
    @object = membership
    @name = "#{membership.user.full_name}'s Membership"
    @klass = membership.class
  end
end
