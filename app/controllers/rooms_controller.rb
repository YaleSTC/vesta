# frozen_string_literal: true
# Controller for Rooms
class RoomsController < ApplicationController
  before_action :set_room, only: :show

  def show
  end

  def new
    @room = Room.new
  end

  def create
    result = RoomCreator.new(room_params).create!
    @room = result[:object] ? result[:object] : Room.new
    handle_create(**result)
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:number, :suite_id, :beds)
  end
end
