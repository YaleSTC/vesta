# frozen_string_literal: true
#
# Service object to update groups
class GroupUpdater < Updater
  # Initialize a GroupUpdater
  #
  # @param group [Group] The group object to be updated
  # @param params [#to_h] The new attributes
  def initialize(group:, params:)
    super(object: group, name_method: :name, params: params)
  end

  private

  def success
    { object: [object.draw, object],
      msg: { success: "#{object.send(name_method)} updated." } }
  end
end
