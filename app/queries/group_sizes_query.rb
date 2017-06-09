# frozen_string_literal: true

# Query to return all of the group sizes in the database.
class GroupSizesQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a GroupSizesQuery
  #
  # @param relation [Group::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = Group.all)
    @relation = relation
  end

  # Execute the group sizes query
  #
  # @return [Array<Integer>] the group sizes in the relation
  def call
    @relation.select(:size).distinct.collect(&:size).sort
  end
end
