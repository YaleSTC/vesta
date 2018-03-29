# frozen_string_literal: true

# Query to return all suites, collected by suite size, for a passed relation.
# Defaults to all suites.
class SuitesBySizeQuery
  # See IntentMetricsQuery for explanation
  class << self
    delegate :call, to: :new
  end

  # Initialize a SuitesBySizeQuery
  #
  # @param relation [Suite::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = Suite.all)
    @relation = relation
  end

  # Execute the query
  #
  # @return [Hash{Integer=>Array<Suite>}] the suites in the relation collected
  #   by size and ordered by number
  def call
    result = @relation.includes(:building, :draws, :draw_suites).order(:number)
                      .group_by(&:size)
    result.default = []
    result
  end
end
