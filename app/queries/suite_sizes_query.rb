# frozen_string_literal: true

# Query to return all of the suite sizes in the database.
class SuiteSizesQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a SuiteSizesQuery
  #
  # @param relation [Suite::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = Suite.all)
    @relation = relation
  end

  # Execute the suite sizes query
  #
  # @return [Array<Integer>] the suite sizes in the relation
  def call
    @relation.select(:size).distinct.collect(&:size).sort
  end
end
