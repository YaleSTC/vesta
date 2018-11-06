# frozen_string_literal: true

# Query to return the groups and clips ready for lottery grouped by size
class LotteriesBySizeQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a LotteriesBySizeQuery
  def initialize
    @sort = College.current.size_sort
    @advantage = College.current.advantage_clips
  end

  # Execute the groups for lottery query.
  #
  # @param draw [Draw] The draw to restrict scope to.
  # @return [Hash<Array<LotteryAssignment>>] A hash that has a key for every
  #   lottery assignment size that points to an array of lottery assignments.
  def call(draw:)
    relation = ObjectsForLotteryQuery.call(draw: draw)
    relation.group_by { |la| sorting_size(la) }
  end

  private

  # determine how to weight the size of clips
  def sorting_size(lottery_assignment)
    return lottery_assignment.groups.map(&:size).max if maximizing?
    lottery_assignment.groups.map(&:size).min
  end

  # note: this returns false if sort is 'no_sort'
  def maximizing?
    @sort == 'descending' && @advantage || @sort == 'ascending' && !@advantage
  end
end
