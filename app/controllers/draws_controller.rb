# frozen_string_literal: true
#
# Controller for Draws
class DrawsController < ApplicationController # rubocop:disable ClassLength
  prepend_before_action :set_draw, except: %i(index new create)
  before_action :calculate_metrics, only: %i(show activate start_lottery
                                             start_selection
                                             lottery_confirmation)

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

  def bulk_on_campus
    result = BulkOnCampusUpdater.update(draw: @draw)
    # note that BulkOnCampusUpdater.update always returns a success hash with
    # :object set to @draw, so we don't need to handle a fallback case via
    # handle_action
    handle_action(**result)
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
      result[:path] = suite_summary_draw_path(@draw)
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

  def lottery_confirmation; end

  def start_lottery
    @lottery_starter = DrawLotteryStarter.new(draw: @draw)
    result = @lottery_starter.start
    handle_action(action: 'lottery_confirmation', **result)
  end

  def lottery; end

  def oversubscription
    calculate_suite_metrics
    calculate_group_metrics
    calculate_oversub_metrics
  end

  def toggle_size_lock
    result = DrawSizeLockToggler.toggle(draw: @draw, size: params[:size])
    handle_action(path: params[:redirect_path], **result)
  end

  def start_selection
    result = DrawSelectionStarter.start(draw: @draw)
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
    params.require(:draw).permit(:name, :intent_deadline, :intent_locked,
                                 suite_ids: [], student_ids: [],
                                 locked_sizes: [])
  end

  def suites_update_params
    params.require(:draw_suites_update).permit(suite_edit_param_hash)
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
    calculate_suite_metrics
    calculate_group_metrics
    calculate_oversub_metrics
    calculate_ungrouped_students_metrics
  end

  def calculate_suite_metrics
    @suite_sizes = SuiteSizesQuery.new(@draw.suites.available).call
    @suite_counts = @draw.suites.available.group(:size).count
  end

  def calculate_group_metrics
    @draw_sizes = DrawSizesQuery.call(draw: @draw)
    empty_groups_hash = @draw_sizes.map { |s| [s, []] }.to_h
    @groups = @draw.groups.includes(:leader)
    @groups_by_size =
      empty_groups_hash.merge(@groups.sort_by { |g| Group.statuses[g.status] }
                                     .group_by(&:size))
  end

  def calculate_oversub_metrics # rubocop:disable AbcSize
    return unless policy(@draw).oversub_report?
    zeroed_group_hash = @suite_sizes.map { |s| [s, 0] }.to_h
    @group_counts = zeroed_group_hash.merge(@groups.group(:size).count)
    @locked_counts = zeroed_group_hash.merge(@groups.where(status: 'locked')
                                                    .group(:size).count)
    @diff = @suite_sizes.map do |size|
      [size, @suite_counts[size] - @group_counts[size]]
    end.to_h
  end

  def calculate_ungrouped_students_metrics
    @ungrouped_students = UngroupedStudentsQuery.new(@draw.students).call
                                                .group_by(&:intent)
    @ungrouped_students.delete('off_campus')
  end

  def prepare_suites_edit_data # rubocop:disable AbcSize, MethodLength
    @suite_sizes ||= SuiteSizesQuery.new(Suite.available).call
    @suites_update ||= DrawSuitesUpdate.new(draw: @draw)
    base_suites = Suite.available.order(:number)
    empty_suite_hash = @suite_sizes.map { |s| [s, []] }.to_h
    @current_suites = empty_suite_hash.merge(
      @draw.suites.available.includes(:draws).order(:number).group_by(&:size)
    )
    @drawless_suites = empty_suite_hash.merge(
      DrawlessSuitesQuery.new(base_suites).call.group_by(&:size)
    )
    @drawn_suites = empty_suite_hash.merge(
      SuitesInOtherDrawsQuery.new(base_suites).call(draw: @draw)
                             .group_by(&:size)
    )
  end

  def prepare_students_edit_data
    @students_update ||= DrawStudentsUpdate.new(draw: @draw)
    @student_assignment_form ||= DrawStudentAssignmentForm.new(draw: @draw)
    @class_years = AvailableStudentClassYearsQuery.call
    @students = @draw.students.order(:last_name)
    @available_students_count = UngroupedStudentsQuery.call.where(draw_id: nil)
                                                      .count
  end

  def process_bulk_assignment
    result = DrawStudentsUpdate.update(draw: @draw,
                                       params: students_update_params)
    @students_update = result[:update_object]
    if @students_update
      prepare_students_edit_data
      result[:action] = 'student_summary'
    else
      result[:path] = student_summary_draw_path(@draw)
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
      result[:path] = student_summary_draw_path(@draw)
    end
    result
  end

  def suite_edit_param_hash
    suite_edit_sizes.flat_map do |s|
      DrawSuitesUpdate::CONSOLIDATED_ATTRS.map { |p| ["#{p}_#{s}".to_sym, []] }
    end.to_h
  end

  def suite_edit_sizes
    @suite_edit_sizes ||= SuiteSizesQuery.new(Suite.available).call
  end
end
