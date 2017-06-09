# frozen_string_literal: true

# Controller for room assignments
class RoomAssignmentsController < ApplicationController
  prepend_before_action :set_room_assignment
  prepend_before_action :set_group
  before_action :set_rooms

  def new; end

  def create
    result = @room_assignment.assign(room_assignment_params)
    handle_action(**result)
  end

  def confirm
    result = @room_assignment.prepare(room_assignment_params)
    handle_action(action: 'new', **result) unless result.empty?
  end

  def edit
    @room_assignment.build_from_group!
  end

  private

  def authorize!
    authorize @room_assignment
  end

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_room_assignment
    @room_assignment = RoomAssignment.new(group: @group)
  end

  def set_rooms
    @rooms = @group&.suite&.rooms&.where('beds > 0')
  end

  def room_assignment_params
    params.require(:room_assignment).permit(*valid_ids)
  end

  def valid_ids
    @room_assignment.valid_field_ids
  end
end
