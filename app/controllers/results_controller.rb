# frozen_string_literal: true
#
# Controller for housing results
class ResultsController < ApplicationController
  def suites
    @suites = SuitesWithRoomsAssignedQuery.call
  end

  def students
    @students = User.includes(:room).where(role: %w(student rep))
                    .where.not(room_id: nil).order(:last_name)
  end

  private

  def authorize!
    authorize :results, :show?
  end
end
