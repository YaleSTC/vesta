# frozen_string_literal: true

# Query to return the suites that don't belong to any draw. This can be passed
# an existing relation for a subset of all Suites.
class DrawlessSuitesQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize an DrawlessSuitesQuery
  #
  # @param relation [Suite::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = Suite.all)
    @relation = relation
  end

  # Execute the drawless suites query. Performs an left outer join with the
  # draw_suites table. See http://stackoverflow.com/a/31524866 for more
  # details.
  #
  # @return [Array<Suite>] the drawless suites in the relation
  def call
    @relation.includes(:draw_suites).where(draw_suites: { suite_id: nil })
  end
end
