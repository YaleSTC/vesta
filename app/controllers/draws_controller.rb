# frozen_string_literal: true

# Controller for Draws
class DrawsController < ApplicationController # rubocop:disable ClassLength
  prepend_before_action :set_draw, except: %i(index new create)
  before_action :calculate_metrics, only: %i(show activate start_lottery
                                             start_selection
                                             lottery_confirmation)

  def show
    calculate_selection_metrics if policy(@draw).selection_metrics?
  end

  def index
    @draws = Draw.all.order(:name)
  end

  def new
    @draw = Draw.new
  end

  def create
    result = Creator.create!(params: draw_params, klass: Draw,
                             name_method: :name)
    @draw = result[:record]
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = Updater.update(object: @draw, name_method: :name,
                            params: draw_params)
    @draw = result[:record]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.destroy(object: @draw, name_method: :name)
    handle_action(path: draws_path, **result)
  end

  def activate
    result = DrawActivator.activate(draw: @draw)
    handle_action(action: 'show', **result)
  end

  def intent_report
    @filter = IntentReportFilter.new
    @students_by_intent = @draw.students.order(:intent, :last_name)
                               .group_by(&:intent)
    @intent_metrics = @students_by_intent.transform_values(&:count)
  end

  def filter_intent_report
    @filter = IntentReportFilter.new(filter_params)
    @students_by_intent = @filter.filter(@draw.students)
                                 .order(:intent, :last_name).group_by(&:intent)
    @intent_metrics = @students_by_intent.transform_values(&:count)
    render action: 'intent_report'
  end

  def bulk_on_campus
    result = BulkOnCampusUpdater.update(draw: @draw)
    # note that BulkOnCampusUpdater.update always returns a success hash with
    # :redirect_object set to @draw, so we don't need to handle a fallback case
    # via handle_action
    handle_action(**result)
  end

  def suite_summary
    suites = @draw.suites.includes(:rooms).available.where(medical: false)
    @all_sizes = SuiteSizesQuery.new(suites).call
    @suites_by_size = SuitesBySizeQuery.new(suites).call
    @suites_by_size.default = []
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
               { redirect_object: nil, action: 'student_summary',
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

  def lottery
    @groups = @draw.groups.includes(:leader).order('users.last_name')
  end

  def oversubscription
    calculate_suite_metrics
    calculate_group_metrics
    calculate_oversub_metrics
  end

  def toggle_size_lock
    result = DrawSizeLockToggler.toggle(draw: @draw, size: params[:size])
    handle_action(path: params[:redirect_path], **result)
  end

  def lock_all_sizes
    @draw.locked_sizes = @draw.suite_sizes
    msg_hash = if @draw.save
                 { success: 'All group sizes locked.' }
               else
                 errors = @draw.errors.full_messages.join(', ')
                 { error: "Size locking failed: #{errors}" }
               end
    handle_action(redirect_object: nil, path: params[:redirect_path],
                  msg: msg_hash)
  end

  def start_selection
    result = DrawSelectionStarter.start(draw: @draw)
    handle_action(action: 'show', **result)
  end

  def select_suites
    @groups = @draw.next_groups
    if @groups.empty?
      result = DrawResultsStarter.start(draw: @draw)
      @draw.update!(status: 'results')
      flash[:success] = 'All groups have suites!'
      handle_action(**result) && return
    end
    @suite_selector = BulkSuiteSelectionForm.new(groups: @groups)
    draw_suites = @draw.suites.available.where(size: @groups.map(&:size))
    @suites_by_size = SuitesBySizeQuery.new(draw_suites).call
  end

  def assign_suites
    @groups = @draw.next_groups
    @suite_selector = BulkSuiteSelectionForm.new(groups: @groups)
    @suite_selector.prepare(params: suite_selector_params)
    result = @suite_selector.submit
    handle_action(**result, path: select_suites_draw_path(@draw))
  end

  def reminder
    # note that this will always redirect to draw show
    result = ReminderQueuer.queue(draw: @draw, type: draw_params['email_type'])
    handle_action(**result)
  end

  def results
    @suites_with_results = SuitesWithRoomsAssignedQuery.new(@draw.suites).call
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
                                 :email_type, :locking_deadline,
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

  def suite_selector_params
    params.require(:bulk_suite_selection_form)
          .permit(@suite_selector.valid_field_ids)
  end

  def set_draw
    @draw = Draw.includes(:groups, :suites).find(params[:id])
  end

  def calculate_metrics
    calculate_sizes
    calculate_suite_metrics
    calculate_group_metrics
    calculate_oversub_metrics
    calculate_ungrouped_students_metrics
  end

  def calculate_sizes
    @suite_sizes ||= @draw.suite_sizes
    @group_sizes ||= @draw.group_sizes
    @sizes ||= (@suite_sizes + @group_sizes).uniq.sort
  end

  def calculate_suite_metrics
    @suite_counts = @draw.suites.available.group(:size).count
    @suite_counts.default = 0
  end

  def calculate_group_metrics
    @groups = @draw.groups.includes(:leader)
    @groups_by_size = @groups.sort_by { |g| Group.statuses[g.status] }
                             .group_by(&:size)
    @groups_by_size.default = []
  end

  def calculate_oversub_metrics
    return unless policy(@draw).oversub_report?
    calculate_sizes
    @group_counts = @groups.group(:size).count
    @group_counts.default = 0
    @locked_counts = @groups.where(status: 'locked').group(:size).count
    @locked_counts.default = 0
    @diff = @sizes.map do |size|
      [size, @suite_counts[size] - @group_counts[size]]
    end.to_h
  end

  def calculate_ungrouped_students_metrics
    @ungrouped_students = UngroupedStudentsQuery.new(@draw.students).call
                                                .group_by(&:intent)
    @ungrouped_students.delete('off_campus')
  end

  def calculate_selection_metrics
    size = current_user.group.size
    @without_suites = @draw.groups.includes(:suite)
                           .where(size: size, suites: { group_id: nil })
                           .order(:lottery_number)
    @valid_suites = @draw.suites.includes(:building).available
                         .where(medical: false, size: size).group_by(&:building)
  end

  def prepare_suites_edit_data # rubocop:disable AbcSize, MethodLength
    draw_suites = @draw.suites.available.where(medical: false)
    all_suites = Suite.available.where(medical: false)
    @suite_sizes ||= SuiteSizesQuery.new(all_suites).call
    @suites_update ||= DrawSuitesUpdate.new(draw: @draw)
    base_suites = all_suites.order(:number)
    empty_suite_hash = @suite_sizes.map { |s| [s, []] }.to_h
    @current_suites = empty_suite_hash.merge(
      draw_suites.includes(:draws).order(:number).group_by(&:size)
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
