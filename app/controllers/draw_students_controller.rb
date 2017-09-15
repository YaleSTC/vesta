# frozen_string_literal: true

# Controller for Draw Students
class DrawStudentsController < ApplicationController
  prepend_before_action :set_draw

  def edit
    prepare_students_edit_data
  end

  def update
    result = DrawStudentAssignmentForm.submit(draw: @draw,
                                              params: student_assignment_params)
    @student_assignment_form = result[:update_object]
    prepare_students_edit_data
    handle_action(action: 'edit', **result)
  end

  def bulk_assign
    result = DrawStudentsUpdate.update(draw: @draw,
                                       params: students_update_params)
    @students_update = result[:update_object]
    prepare_students_edit_data
    handle_action(action: 'edit', **result)
  end

  private

  def authorize!
    authorize :draw_student
  end

  def prepare_students_edit_data
    @students_update ||= DrawStudentsUpdate.new(draw: @draw)
    @student_assignment_form ||= DrawStudentAssignmentForm.new(draw: @draw)
    @class_years = AvailableStudentClassYearsQuery.call
    @students = @draw.students.order(:last_name)
    @available_students_count = UngroupedStudentsQuery.call.where(draw_id: nil)
                                                      .count
  end

  def set_draw
    @draw = Draw.includes(:students).find(params[:draw_id])
  end

  def student_assignment_params
    params.fetch(:draw_student_assignment_form, {}).permit(%i(username adding))
  end

  def students_update_params
    params.fetch(:draw_students_update, {}).permit(:class_year)
  end
end
