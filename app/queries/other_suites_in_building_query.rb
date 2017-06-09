# frozen_string_literal: true

# Query object to retrieve all other suites in the same building as a passed
# suite. Can be passed a relation in the initializer to scope the query.
class OtherSuitesInBuildingQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # initialize an OtherSuitesInBuildingQuery instance
  #
  # @param [Suite::ActiveRecord_Relation] base relation to use for the query
  #   object, defaults to all suites
  def initialize(relation = Suite.all)
    @relation = relation
  end

  # Execute the query
  #
  # @param suite [Suite] the suite to use as a reference
  # @return [Suite::ActiveRecord_Relation] the other suites in the same building
  #   as the passed suite
  def call(suite:)
    @relation.where(building: suite.building).where.not(id: suite.id)
             .available.order(:number)
  end
end
