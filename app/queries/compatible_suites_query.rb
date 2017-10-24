# frozen_string_literal: true

# Query to return all suites available for a group.
# Eager loads buildings and rooms.
# Requires a group for initialization.
class CompatibleSuitesQuery
  # See IntentMetricsQuery for explanation
  class << self
    delegate :call, to: :new
  end

  # Initialize a CompatibleSuitesQuery
  #
  # @param relation [Suite::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = Suite.all)
    @relation = relation
  end

  # Execute the query
  #
  # @param [Group::ActiveRecord_Relation]
  # @return [Hash{Integer=>Array<Suite>}] the suites in the relation
  def call(group)
    @relation.includes(:building, :rooms, :draws).available
             .where(size: group.size)
  end
end
