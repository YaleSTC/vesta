# frozen_string_literal: true

# Query object to identify and return the next available groups to select
# suites.
class NextGroupsQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a NextGroupsQuery instance
  #
  # @param relation [Group::ActiveRecord_Relation] base relation to use for the
  #   query object, defaults to all groups
  def initialize(relation = Group.all)
    @relation = relation
  end

  # Execute the query
  #
  # @param draw [Draw] the draw in question
  # @return [Array<Group>] the next available groups for suite selection by
  #   lottery number
  def call(draw:)
    lottery_number = next_lottery_number(draw)
    return [] unless lottery_number
    @relation.where(draw: draw, lottery_number: lottery_number)
  end

  private

  def next_lottery_number(draw)
    draw.groups.includes(:suite).where(suites: { group_id: nil })
        .minimum(:lottery_number)
  end
end
