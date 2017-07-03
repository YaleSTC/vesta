# frozen_string_literal: true

# Query to return the suites that belong to at least one draw, with the
# exclusion of those that belong to the passed draw.
class SuitesInOtherDrawsQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize an SuitesInOtherDrawsQuery
  #
  # @param relation [Suite::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = Suite.all)
    @relation = relation
  end

  # Execute the drawn suites query. Performs an left outer join with the
  # draws_suites table. See http://stackoverflow.com/a/31524866 for more
  # details.
  #
  # @param draw [Draw] the draw to exclude
  # @return [Array<Suite>] the undrawn suites in the relation
  def call(draw: nil)
    base = @relation.includes(:draws).includes(:draw_suites)
                    .where.not(draw_suites: { suite_id: nil })
    return base unless draw
    base.where.not(id: draw.suite_ids)
  end
end
