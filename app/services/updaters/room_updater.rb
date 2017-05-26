# frozen_string_literal: true

# Service object to update Rooms
class RoomUpdater < Updater
  def initialize(room:, params:)
    super(object: room, params: params, name_method: :number)
  end

  private

  def success
    {
      redirect_object: [object.suite.building, object.suite, object],
      record: object,
      msg: { notice: "#{object.send(name_method)} updated." }
    }
  end
end
