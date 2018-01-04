# frozen_string_literal: true

# Query object to identify and return the next available groups to select
# suites.
class NextGroupsQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Execute the query
  #
  # @param draw [Draw] the draw in question
  # @param size [Integer] the size of groups
  # @return [Array<Group>] the next available groups for suite selection by
  #   lottery number
  def call(draw:, size: nil)
    lottery = next_lottery(draw, lottery_filters(size))
    return [] unless lottery
    lottery.groups
  end

  private

  def lottery_filters(size = nil)
    return { selected: false } unless size
    { selected: false, groups: { size: size } }
  end

  def next_lottery(draw, attrs)
    draw.lottery_assignments.includes(:groups).where(**attrs)
        .order(:number).first
  end
end
