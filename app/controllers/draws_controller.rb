# frozen_string_literal: true
#
# Controller for Draws
class DrawsController < ApplicationController
  prepend_before_action :set_draw, only: [:show, :edit, :update, :destroy,
                                          :activate, :intent_report,
                                          :filter_intent_report]
  before_action :calculate_metrics, only: [:show, :activate]

  def show; end

  def new
    @draw = Draw.new
  end

  def create
    result = DrawCreator.new(draw_params).create!
    @draw = result[:record]
    handle_action(action: 'new', **result)
  end

  def edit
  end

  def update
    result = Updater.new(object: @draw, name_method: :name,
                         params: draw_params).update
    @draw = result[:record]
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

  def intent_report
    @filter = IntentReportFilter.new
    @students = @draw.students.order(:intent)
  end

  def filter_intent_report
    @filter = IntentReportFilter.new(filter_params)
    @students = @filter.filter(@draw.students)
    render action: 'intent_report'
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

  def filter_params
    params.fetch(:intent_report_filter, {}).permit(intents: [])
  end

  def set_draw
    @draw = Draw.find(params[:id])
  end

  def calculate_metrics
    @intent_metrics = IntentMetricsQuery.call(@draw)
  end
end
