# frozen_string_literal: true

# Controller for Clips
class ClipsController < ApplicationController
  prepend_before_action :set_data, only: %i(new create)
  prepend_before_action :set_clip, except: %i(new create)
  before_action :set_groups, only: %i(edit)

  def new
    # Admins and reps have the same view when creating clips
    @new_clip_form = NewClipForm.new(role: current_user.role,
                                     params: { draw_id: @draw.id })
  end

  def create
    result = NewClipForm.new(role: current_user.role,
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
    params.require(:new_clip_form).permit(:draw_id, group_ids: [])
          .tap { |p| process_new_form_params(p) }
  end

  def process_new_form_params(p)
    p[:group_ids] << @group.id.to_s
  end

  def set_data
    set_group
    set_draw
    set_groups
  end

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_clip
    @clip = Clip.find(params[:id])
  end

  def set_draw
    @draw = @group.draw
  end

  def set_groups
    @groups = GroupsForClippingQuery.call(draw: @draw || @clip.draw,
                                          group: @group || @clip&.groups&.first)
    @groups += @clip.groups if @clip
  end
end
