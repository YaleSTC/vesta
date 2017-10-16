# frozen_string_literal: true

# Query to return a hash of object counts keyed by the object :size.
# Defaults to zero.
class CountBySizeQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a CountBySizeQuery.  A relation is required.
  #
  # @param relation [ActiveRecord::Relation] the base relation for the query
  def initialize(relation)
    @relation = relation
  end

  # Execute the count by sizes query
  #
  # @return [Hash(:size => Integer)] A hash mapping :size
  # to a count of the objects of that size
  def call
    result ||= @relation.group(:size).count
    result.default = 0
    result
  end
end
