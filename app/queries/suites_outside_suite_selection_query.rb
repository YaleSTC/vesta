# frozen_string_literal: true

# Query object to return all suites that are both outside a draw and within a
# draw that is currently not in suite selection.
class SuitesOutsideSuiteSelectionQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a SuitesOutsideSuiteSelectionQuery instance
  #
  # @param relation [Suite::ActiveRecord_Relation] base relation to use for the
  #   query object, defaults to all suites
  def initialize(relation = Suite.all)
    @relation = relation.available.includes(:draws)
  end

  # Execute the query
  #
  # @param [Group::ActiveRecord_Relation]
  # @return [Hash{Integer=>Array<Suite>}] the suites in the relation that are
  #   both drawless and are in a draw that isn't in suite selection
  def call(group)
    ids = @relation.where(size: group.size)
                   .where(draws: { status: 'suite_selection' }).map(&:id)
    @relation.where(size: group.size).where.not(id: ids).order(:number)
  end
end
