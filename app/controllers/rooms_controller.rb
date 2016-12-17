# frozen_string_literal: true
# Controller for Rooms
class RoomsController < ApplicationController
  prepend_before_action :set_room, only: %i(show edit update destroy)

  def show
  end

  def new
    @room = Room.new
  end

  def create
    result = RoomCreator.new(room_params).create!
    @room = result[:object] ? result[:object] : Room.new
    handle_action(action: 'new', **result)
  end

  def edit
  end

  def update
    result = Updater.new(object: @room, name_method: :number,
                         params: room_params).update
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @room, name_method: :number).destroy
    handle_action(**result)
  end

  private

  def authorize!
    if @room
      authorize @room
    else
      authorize Room
    end
  end

  def room_params
    params.require(:room).permit(:number, :suite_id, :beds)
  end

  def set_room
    @room = Room.find(params[:id])
  end
end
