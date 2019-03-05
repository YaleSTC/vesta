# frozen_string_literal: true

# Query to return result information about students in the current college.
class ResultsQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a ResultsQuery instance
  #
  # @param relation [User::ActiveRecord_Relation] base relation to use for the
  #   query object, defaults to active users
  def initialize(relation = User.active)
    @relation = relation
  end

  # Execute the query!
  # @return [User::ActiveRecord_Relation]
  def call
    @relation.where(role: %w(student rep), college: College.current)
             .active
             .includes(:draw, :room, group: %i(lottery_assignment suite leader))
             .order(:last_name)
  end
end
