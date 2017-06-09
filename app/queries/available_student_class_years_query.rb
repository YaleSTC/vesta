# frozen_string_literal: true

# Query to return the class years of all students who are both not in a draw and
# not in a group. This can be passed an existing relation for a subset of
# students.
class AvailableStudentClassYearsQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize an AvailableStudentClassYearsQuery
  #
  # @param relation [User::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = User.all)
    @relation = relation
  end

  # Execute the class year query.
  #
  # @return [Array<Integer>] the valid class years
  def call
    UngroupedStudentsQuery.new(@relation).call.where(draw_id: nil)
                          .map(&:class_year).uniq.sort
  end
end
