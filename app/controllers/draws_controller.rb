# frozen_string_literal: true
#
# Controller for Draws
class DrawsController < ApplicationController # rubocop:disable ClassLength
  prepend_before_action :set_draw, except: %i(index new create)
  before_action :calculate_metrics, only: [:show, :activate]

  def show; end

  def index
    @draws = Draw.all
  end

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

  def suite_summary
    @all_sizes = SuiteSizesQuery.new(Suite.available).call
    @suites_by_size = SuitesBySizeQuery.new(@draw.suites.available).call
  end

  def suites_edit
    prepare_suites_edit_data
  end

  def suites_update
    result = DrawSuitesUpdate.update(draw: @draw, params: suites_update_params)
    @suites_update = result[:update_object]
    if @suites_update
      prepare_suites_edit_data
      result[:action] = 'suites_edit'
    else
      result[:path] = draw_suite_summary_path(@draw)
    end
    handle_action(**result)
  end

  def student_summary
    prepare_students_edit_data
  end

  def students_update
    result = if !students_update_params.empty?
               process_bulk_assignment
             elsif !student_assignment_params.empty?
               process_student_assignment
             else
               prepare_students_edit_data
               { object: nil, action: 'student_summary',
                 msg: { error: 'Invalid update submission' } }
             end
    handle_action(**result)
  end

  def process_bulk_assignment
    result = DrawStudentsUpdate.update(draw: @draw,
                                       params: students_update_params)
    @students_update = result[:update_object]
    if @students_update
      prepare_students_edit_data
      result[:action] = 'student_summary'
    else
      result[:path] = draw_student_summary_path(@draw)
    end
    result
  end

  def process_student_assignment
    result = DrawStudentAssignmentForm.submit(draw: @draw,
                                              params: student_assignment_params)
    @student_assignment_form = result[:update_object]
    if @student_assignment_form
      prepare_students_edit_data
      result[:action] = 'student_summary'
    else
      result[:path] = draw_student_summary_path(@draw)
    end
    result
  end

  def lottery; end

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
                                                          student_ids: [],
                                                          locked_sizes: [])
  end

  def suites_update_params
    params.require(:draw_suites_update).permit(:size, suite_ids: [],
                                                      drawn_suite_ids: [],
                                                      undrawn_suite_ids: [])
  end

  def students_update_params
    params.fetch(:draw_students_update, {}).permit(:class_year)
  end

  def student_assignment_params
    params.fetch(:draw_student_assignment_form, {}).permit(%i(username adding))
  end

  def filter_params
    params.fetch(:intent_report_filter, {}).permit(intents: [])
  end

  def set_draw
    @draw = Draw.includes(:groups, :suites).find(params[:id])
  end

  def calculate_metrics
    calculate_intent_metrics
    calculate_group_metrics
    calculate_oversub_metrics
  end

  def calculate_intent_metrics
    return unless policy(@draw).intent_summary?
    @intent_metrics = IntentMetricsQuery.call(@draw)
  end

  def calculate_group_metrics
    @suite_sizes = SuiteSizesQuery.new(@draw.suites.available).call
    empty_groups_hash = @suite_sizes.map { |s| [s, []] }.to_h
    @groups = @draw.groups.includes(:leader)
    @groups_by_size =
      empty_groups_hash.merge(@groups.sort_by { |g| Group.statuses[g.status] }
                                     .group_by(&:size))
  end

  def calculate_oversub_metrics # rubocop:disable AbcSize
    return unless policy(@draw).oversub_report?
    @suite_counts = @draw.suites.available.group(:size).count
    zeroed_group_hash = @suite_sizes.map { |s| [s, 0] }.to_h
    @group_counts = zeroed_group_hash.merge(@groups.group(:size).count)
    @locked_counts = zeroed_group_hash.merge(@groups.where(status: 'locked')
                                                    .group(:size).count)
    @diff = @suite_sizes.map do |size|
      [size, @suite_counts[size] - @group_counts[size]]
    end.to_h
  end

  def prepare_suites_edit_data # rubocop:disable AbcSize
    @suites_update ||= DrawSuitesUpdate.new(draw: @draw)
    @size = params[:size] ? params[:size].to_i : @suites_update.size
    base_suites = Suite.where(size: @size).available.order(:number)
    @current_suites = @draw.suites.available.includes(:draws).where(size: @size)
                           .order(:number)
    @drawless_suites = DrawlessSuitesQuery.new(base_suites).call
    @drawn_suites = SuitesInOtherDrawsQuery.new(base_suites).call(draw: @draw)
  end

  def prepare_students_edit_data
    @students_update ||= DrawStudentsUpdate.new(draw: @draw)
    @student_assignment_form ||= DrawStudentAssignmentForm.new(draw: @draw)
    @class_years = AvailableStudentClassYearsQuery.call
    @students = @draw.students.order(:last_name)
    @available_students_count = UngroupedStudentsQuery.call.where(draw_id: nil)
                                                      .count
  end
end
