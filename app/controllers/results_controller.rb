# frozen_string_literal: true

require 'csv'

# Controller for housing results
class ResultsController < ApplicationController
  EXPORT_HEADERS = %i(last_name first_name username suite room).freeze

  before_action :collect_student_data, only: %i(students export)

  def suites
    @suites = SuitesWithRoomsAssignedQuery.call
  end

  def students
    @students = @students.order(:last_name)
  end

  def export
    send_data csv_contents(params['sort_by_suite']), filename: csv_filename,
                                                     type: 'text/csv'
  end

  private

  def authorize!
    authorize :results, :show?
  end

  def collect_student_data
    @students = User.includes(room: :suite).where(role: %w(student rep))
                    .where.not(room_id: nil)
  end

  def csv_contents(sort_by_suite = false)
    students = sort_students_data(sort_by_suite)
    CSV.generate do |csv|
      csv << EXPORT_HEADERS.map(&:to_s)
      students.each do |student|
        csv << row_for(student)
      end
    end
  end

  def sort_students_data(sort_by_suite)
    return @students.order(:last_name) unless sort_by_suite
    @students.order(%w(suites.number rooms.number users.last_name))
  end

  def row_for(user)
    [
      user.last_name, user.first_name, user.username, user.room.suite.number,
      user.room.number
    ]
  end

  def csv_filename
    time_str = Time.zone.today.to_s(:number)
    "vesta_export_#{time_str}.csv"
  end
end
