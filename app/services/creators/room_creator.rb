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

  private

  def success
    {
      redirect_object: [obj.suite.building, obj.suite, obj],
      record: obj,
      msg: { success: "#{obj.send(name_method)} created." }
    }
  end
end
