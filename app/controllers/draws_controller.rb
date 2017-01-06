# frozen_string_literal: true
#
# Controller for Draws
class DrawsController < ApplicationController
  prepend_before_action :set_draw, only: [:show, :edit, :update, :destroy,
                                          :activate]
  before_action :calculate_metrics, only: [:show, :activate]

  def show; end

  def new
    @draw = Draw.new
  end

  def create
    result = DrawCreator.new(draw_params).create!
    @draw = result[:object] ? result[:object] : Draw.new
    handle_action(action: 'new', **result)
  end

  def edit
  end

  def update
    result = Updater.new(object: @draw, name_method: :name,
                         params: draw_params).update
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @draw, name_method: :name).destroy
    handle_action(**result)
  end

  def activate
    result = DrawActivator.activate(draw: @draw)
    handle_action(action: 'show', **result)
  end

  private

  def authorize!
    if @draw
      authorize @draw
    else
      authorize Draw
    end
  end

  def draw_params
    params.require(:draw).permit(:name, :intent_deadline, suite_ids: [],
                                                          student_ids: [])
  end

  def set_draw
    @draw = Draw.find(params[:id])
  end

  def calculate_metrics
    @intent_metrics = IntentMetricsQuery.call(@draw)
  end
end
