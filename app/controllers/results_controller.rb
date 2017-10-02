# frozen_string_literal: true

# Controller for housing results
class ResultsController < ApplicationController
  before_action :collect_student_data, only: %i(students export)

  def suites
    @suites = SuitesWithRoomsAssignedQuery.call
  end

  def students
    @students = @students.order(:last_name)
  end

  def export
    parameters = { students: @students, sort_by_suite: params['sort_by_suite'] }
    csv_contents = ResultsCSVGenerator.generate(parameters)
    send_data csv_contents, filename: csv_filename, type: 'text/csv'
  end

  private

  def authorize!
    authorize :results, :show?
  end

  def collect_student_data
    @students = User.includes(room: :suite).where(role: %w(student rep))
                    .where.not(room_id: nil)
  end

  def csv_filename
    time_str = Time.zone.today.to_s(:number)
    "vesta_export_#{time_str}.csv"
  end
end
