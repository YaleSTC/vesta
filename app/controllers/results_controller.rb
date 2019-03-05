# frozen_string_literal: true

# Controller for housing results
class ResultsController < ApplicationController
  def suites
    @suites = SuitesWithRoomsAssignedQuery.call
  end

  def students
    @students = StudentsWithRoomsAssignedQuery.call
  end

  def export
    s = ResultsQuery.call
    a = %I[username email student_id last_name first_name draw_name intent
           group_name lottery_number building_name suite_number room_number]

    result = CSVGenerator.generate(data: s, attributes: a, name: 'students')
    handle_file_action(**result)
  end

  private

  def authorize!
    authorize :results, :show?
  end
end
