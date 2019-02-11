# frozen_string_literal: true

# Controller for housing results
class ResultsController < ApplicationController
  def suites
    @suites = SuitesWithRoomsAssignedQuery.call
  end

  def students
    @students = User.active
                    .includes(room: :suite)
                    .where(role: %w(student rep), college: College.current)
                    .where.not(room_assignments: { room_id: nil })
                    .order(:last_name)
  end

  def export
    s = User.active.where(role: %w(student rep), college: College.current)
            .includes(:draw, :room, group: %i(lottery_assignment suite))
            .order(:last_name)
    a = %I[#{User.login_attr} last_name first_name draw_name intent group_name
           lottery_number building_name suite_number room_number]
    result = CSVGenerator.generate(data: s, attributes: a, name: 'students')
    handle_file_action(**result)
  end

  private

  def authorize!
    authorize :results, :show?
  end
end
