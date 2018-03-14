# frozen_string_literal: true

# Controller for housing results
class ResultsController < ApplicationController
  before_action :collect_student_data, only: %i(students export)

  def suites
    @suites = SuitesWithRoomsAssignedQuery.call
  end

  def students; end

  def export
    attributes = %I[#{User.login_attr} last_name first_name suite_number
                    room_number]
    result = CSVGenerator.generate(data: @students, attributes: attributes,
                                   name: 'results')
    handle_file_action(**result)
  end

  private

  def authorize!
    authorize :results, :show?
  end

  def collect_student_data
    base = User.includes(room: :suite).where(role: %w(student rep))
               .where.not(room_id: nil)
    @students = if params['sort_by_suite']
                  base.order(%w(suites.number rooms.number users.last_name))
                else
                  base.order(:last_name)
                end
  end
end
