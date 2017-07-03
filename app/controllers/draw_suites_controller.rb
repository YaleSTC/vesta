# frozen_string_literal: true

# Controller for Draws
class DrawSuitesController < ApplicationController
  layout 'application_with_sidebar', except: %i(new create edit update index)
  prepend_before_action :set_draw
  before_action :set_form_data, only: %i(new edit)

  def index
    suites = @draw.suites.includes(:rooms).available.where(medical: false)
    @all_sizes = SuiteSizesQuery.new(suites).call
    @suites_by_size = SuitesBySizeQuery.new(suites).call
    @suites_by_size.default = []
  end

  def edit_collection
    prepare_suites_edit_data
  end

  def update_collection
    result = DrawSuitesUpdate.update(draw: @draw, params: suites_update_params)
    @suites_update = result[:update_object]
    if @suites_update
      prepare_suites_edit_data
      result[:action] = 'suites_edit'
    else
      result[:path] = draw_suites_path(@draw)
    end
    handle_action(**result)
  end

  private

  def suite_edit_param_hash
    suite_edit_sizes.flat_map do |s|
      DrawSuitesUpdate::CONSOLIDATED_ATTRS.map { |p| ["#{p}_#{s}".to_sym, []] }
    end.to_h
  end

  def suite_edit_sizes
    @suite_edit_sizes ||= SuiteSizesQuery.new(Suite.available).call
  end

  def authorize!
    if @draw_suite
      authorize @draw_suite
    else
      authorize DrawSuite.new(draw: @draw)
    end
  end

  def prepare_suites_edit_data # rubocop:disable AbcSize, MethodLength
    draw_suite = @draw.suites.available.where(medical: false)
    all_suites = Suite.available.where(medical: false)
    @suite_sizes ||= SuiteSizesQuery.new(all_suites).call
    @suites_update ||= DrawSuitesUpdate.new(draw: @draw)
    base_suites = all_suites.order(:number)
    empty_suite_hash = @suite_sizes.map { |s| [s, []] }.to_h
    @current_suites = empty_suite_hash.merge(
      draw_suite.includes(:draws).order(:number).group_by(&:size)
    )
    @drawless_suites = empty_suite_hash.merge(
      DrawlessSuitesQuery.new(base_suites).call.group_by(&:size)
    )
    @drawn_suites = empty_suite_hash.merge(
      SuitesInOtherDrawsQuery.new(base_suites).call(draw: @draw)
                             .group_by(&:size)
    )
  end

  def suites_update_params
    params.require(:draw_suites_update).permit(suite_edit_param_hash)
  end

  def set_draw
    @draw = Draw.includes(:suites).find(params[:draw_id])
  end
end
