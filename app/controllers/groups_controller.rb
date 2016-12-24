# frozen_string_literal: true
# Controller for Groups
class GroupsController < ApplicationController
  prepend_before_action :set_group, only: %i(show edit update destroy)
  before_action :set_draw

  def show; end

  def new
    @group = Group.new(draw: @draw)
  end

  def create
    p = group_params.to_h
    p[:leader_id] = current_user.id unless current_user.admin?
    result = GroupCreator.new(p).create!
    @group = result[:group] ? result[:group] : Group.new(draw: @draw)
    handle_action(path: new_draw_group_path(@draw), **result)
  end

  def edit; end

  def update
    result = GroupUpdater.new(group: @group, params: group_params).update
    handle_action(path: edit_draw_group_path(@draw, @group), **result)
  end

  def destroy
    result = Destroyer.new(object: @group, name_method: :name).destroy
    handle_action(**result)
  end

  private

  def authorize!
    if @group
      authorize @group
    else
      authorize Group
    end
  end

  def group_params
    params.require(:group).permit(:size, :leader_id, member_ids: [])
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def set_draw
    @draw = Draw.find(params[:draw_id])
  end
end
