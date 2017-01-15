# frozen_string_literal: true
#
# Service object to update memberships
class MembershipUpdater < Updater
  # Class method to permit calling :update on the class without instantiating
  # the service object directly
  #
  # @param params [Hash] any parameters to be passed to the initializer
  def self.update(**params)
    new(**params).update
  end

  # Initialize a MembershipUpdater
  #
  # @param membership [Membership] The membership object to be updated
  # @param params [#to_h] The new attributes
  def initialize(membership:, params:)
    super(object: membership, name_method: nil, params: params)
  end

  private

  def success
    { object: [object.group.draw, object.group],
      msg: { success: "#{object.user.full_name} joined group "\
             "#{object.group.name}." } }
  end
end
