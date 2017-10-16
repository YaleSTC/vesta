# frozen_string_literal: true

# Query to return available non-medical suites,
# This can be passed an existing relation for a subset of all suites.
class ValidSuitesQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize an ValidSuitesQuery
  #
  # @param relation [Suite::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = Suite)
    @relation = relation
  end

  # Gets available non-medical suites
  #
  # @return [Suite::ActiveRecord_Relation] a relation containing
  # available non-medical suites
  def call
    @relation.available.where(medical: false)
  end
end
