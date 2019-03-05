# frozen_string_literal: true

# Query to return all students which have a room assigned.
class StudentsWithRoomsAssignedQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a StudentsWithRoomsAssignedQuery instance
  #
  # @param relation [User::ActiveRecord_Relation] base relation to use for the
  #   query object, defaults to active users
  def initialize(relation = User.active)
    @relation = relation
  end

  # Execute the query!
  # @return [User::ActiveRecord_Relation]
  def call
    @relation.where(college: College.current)
             .where(role: %w(student rep))
             .active
             .joins(:draw_membership, :room_assignment)
             .order(:last_name)
  end
end
