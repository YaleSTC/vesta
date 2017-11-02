# frozen_string_literal: true

# Controller for Clips
class ClipsController < ApplicationController
  prepend_before_action :set_draw, only: %i(new create)
  prepend_before_action :set_clip, except: %i(new create)
  before_action :set_groups, only: %i(new edit)

  def new
    @new_clip_form = NewClipForm.new(admin: current_user.admin?,
                                     params: { draw_id: @draw.id })
  end

  def create
    result = NewClipForm.new(admin: current_user.admin?,
                             params: new_clip_form_params).submit
    unless result[:redirect_object].present?
      @new_clip_form = result[:form_object]
      set_groups
    end
    handle_action(action: 'new', **result)
  end

  def show; end

  def edit; end

  def update
    result = ClipUpdater.update(clip: @clip, params: clip_params)
    @clip = result[:record]
    set_groups unless result[:redirect_object].present?
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @clip, name_method: :name).destroy
    handle_action(**result, path: draw_path(@clip.draw))
  end

  private

  def authorize!
    if @clip
      authorize @clip
    else
      authorize Clip.new(draw: @draw)
    end
  end

  def clip_params
    params.require(:clip).permit(:draw_id, group_ids: [])
  end

  def new_clip_form_params
    params.require(:new_clip_form).permit(:draw_id, :add_self, group_ids: [])
          .tap { |p| process_new_form_params(p) }
  end

  def process_new_form_params(p)
    p[:add_self] = '1' if current_user.student?
    p[:group_ids] += [current_user.group&.id.to_s] if p[:add_self] == '1'
  end

  def set_clip
    @clip = Clip.find(params[:id])
  end

  def set_draw
    @draw = Draw.find(params[:draw_id])
  end

  def set_groups
    group = current_user.group
    @groups = GroupsForClippingQuery.call(draw: @draw || @clip.draw,
                                          group: group)
    @groups += @clip.groups if @clip
  end
end
