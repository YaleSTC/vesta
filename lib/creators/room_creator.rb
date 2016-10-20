# frozen_string_literal: true
#
# Service object to create rooms.
class RoomCreator < Creator
  # Initialize a RoomCreator
  #
  # @param [ActionController::Parameters] params The params object from
  #   the RoomsController.
  def initialize(params)
    super(klass: Room, name_method: :number, params: params)
  end
end
