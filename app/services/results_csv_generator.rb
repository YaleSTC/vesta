# frozen_string_literal: true

require 'csv'

# Service object to create a csv for exporting students' room selections.
# Will parse the passed relation for information and add it to a csv which
# it will return.
class ResultsCSVGenerator
  include Callable

  EXPORT_HEADERS = %i(last_name first_name username suite room).freeze

  # Initialize a new CSVGenerator
  #
  # @param students [User::ActiveRecord_Relation] The students to export.
  # @param sort_by_suite [Boolean] If true will sort by suite number,
  # room number, and last name.  Otherwise it will sort only by last name.
  def initialize(students:, sort_by_suite: false)
    @students = students
    @sort_by_suite = sort_by_suite
  end

  # Generate a CSV
  #
  # @return [String] A csv containing each students'
  # last_name, first_name, username, suite number, and room number
  def generate
    students = sort_students_data
    CSV.generate do |csv|
      csv << EXPORT_HEADERS.map(&:to_s)
      students.each do |student|
        csv << row_for(student)
      end
    end
  end

  make_callable :generate

  private

  def sort_students_data
    return @students.order(:last_name) unless @sort_by_suite
    @students.order(%w(suites.number rooms.number users.last_name))
  end

  def row_for(user)
    [
      user.last_name, user.first_name, user.username, user.group&.suite&.number,
      user.room&.number
    ]
  end
end
