# frozen_string_literal: true

# Controller for Rooms
class RoomsController < ApplicationController
  prepend_before_action :set_room, only: %i(show edit update destroy)
  prepend_before_action :set_parents

  def show; end

  def new
    @room = Room.new
  end

  def create
    result = RoomCreator.new(room_params).create!
    @room = result[:record]
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = RoomUpdater.new(room: @room, params: room_params).update
    @room = result[:record]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @room, name_method: :number).destroy
    path = if @room.suite
             building_suite_path(@building, @room.suite)
           else
             buildings_path(@building)
           end
    handle_action(path: path, **result)
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

  def set_parents
    @suite = Suite.find(params[:suite_id])
    @building = Building.find(params[:building_id])
  end
end
