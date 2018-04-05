# frozen_string_literal: true

# Controller for Draws
class DrawsController < ApplicationController # rubocop:disable ClassLength
  prepend_before_action :set_draw, except: %i(index new create)
  before_action :calculate_metrics, only: %i(show activate start_lottery
                                             start_selection
                                             lottery_confirmation
                                             oversubscription prune)

  def show; end

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

  def bulk_on_campus
    result = BulkOnCampusUpdater.update(draw: @draw)
    # note that BulkOnCampusUpdater.update always returns a success hash with
    # :redirect_object set to @draw, so we don't need to handle a fallback case
    # via handle_action
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
    @lottery_starter = DrawLotteryStarter.new(draw: @draw.__getobj__)
    result = @lottery_starter.start
    handle_action(action: 'lottery_confirmation', **result)
  end

  def oversubscription; end

  def toggle_size_lock
    result = DrawSizeLockToggler.toggle(draw: @draw, size: params[:size])
    handle_action(path: params[:redirect_path], **result)
  end

  def lock_all_sizes
    result = Updater.update(object: @draw, name_method: :name,
                            params: { locked_sizes: @draw.suite_sizes })

    handle_action(**result.merge!(redirect_object: nil,
                                  path: params[:redirect_path]))
  end

  def prune
    sizes = if prune_params[:prune_size] == 'all'
              @draw.oversubscribed_sizes
            else
              [prune_params[:prune_size].to_i]
            end
    result = OversubscriptionPruner.prune(draw_report: @draw, sizes: sizes)
    handle_action(path: request.referer, **result)
  end

  def start_selection
    result = DrawSelectionStarter.start(draw: @draw)
    handle_action(action: 'show', **result)
  end

  def reminder
    # note that this will always redirect to draw show
    result = ReminderQueuer.queue(draw: @draw, type: draw_params['email_type'])
    handle_action(**result)
  end

  def results
    @suites_with_results = SuitesWithRoomsAssignedQuery.new(@draw.suites).call
  end

  def group_export
    @groups = @draw.groups.includes(:lottery_assignment)
                   .order('lottery_assignments.number')
    attributes = %i(name lottery_number suite_number)
    result = CSVGenerator.generate(data: @groups, attributes: attributes,
                                   name: 'groups')
    handle_file_action(**result)
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
                                 :allow_clipping, locked_sizes: [])
  end

  def students_update_params
    params.fetch(:draw_students_update, {}).permit(:class_year)
  end

  def student_assignment_params
    params.fetch(:draw_student_assignment_form, {}).permit(%i(username adding))
  end

  def prune_params
    {
      id: params.fetch(:id, ''),
      prune_size: params.fetch(:prune_size, '')
    }
  end

  def set_draw
    @draw = Draw.includes(:suites,
                          groups: [:lottery_assignment, suite: :building])
                .find(params[:id])
  end

  def calculate_metrics
    @draw = DrawReport.new(@draw)
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
end
