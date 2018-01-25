# frozen_string_literal: true

# Controller for housing results
class ResultsController < ApplicationController
  def suites
    @suites = SuitesWithRoomsAssignedQuery.call
  end

  def students
    @students = User.includes(room: :suite)
                    .where(role: %w(student rep))
                    .where.not(room_assignments: { room_id: nil })
                    .order(:last_name)
  end

  def export
    s = User.where(role: %w(student rep))
            .includes(:draw, :room, group: %i(lottery_assignment suite))
            .order(:last_name)
    a = %I[#{User.login_attr} last_name first_name draw_name intent group_name
           lottery_number suite_number room_number]
    result = CSVGenerator.generate(data: s, attributes: a, name: 'students')
    handle_file_action(**result)
  end

  private

  def authorize!
    authorize :results, :show?
  end
end
