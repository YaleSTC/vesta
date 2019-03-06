# frozen_string_literal: true

# Query to return the groups without a suite
class GroupWithoutSuitesQuery
  # See IntentMetricsQuery for explanation
  class << self
    delegate :call, to: :new
  end

  # Initialize a GroupWithoutSuitesQuery
  #
  # @param relation [Group::ActiveRecord_Relation] the base relation for the
  #   group query
  def initialize(relation = Group)
    @relation = relation
  end

  # Execute the query
  #
  # @return [Group::ActiveRecord_Relation] The groups without suites
  def call
    @relation.includes(:suite)
             .where(suites: { suite_assignments: { group_id: nil } })
  end
end
