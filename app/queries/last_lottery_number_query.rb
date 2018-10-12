# frozen_string_literal: true

# Query object to identify and return the lottery number of the last group
# in the draw's suite selection
class LastLotteryNumberQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Execute the query
  #
  # @param draw [Draw] the draw in question
  # @param size [Integer] the size of groups
  # @return [Integer] the lottery number of the last assignment in the draw
  def call(draw:, size: nil)
    lottery = last_lottery(draw, lottery_filters(size))
    return nil unless lottery
    lottery.number
  end

  private

  def lottery_filters(size = nil)
    return { selected: false } unless size
    { selected: false, groups: { size: size } }
  end

  def last_lottery(draw, attrs)
    draw.lottery_assignments.includes(:groups).where(**attrs)
        .order(:number).last
  end
end
