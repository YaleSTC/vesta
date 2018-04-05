# frozen_string_literal: true

# Query to return lottery assignments without groups
class LotteriesWithoutGroupsQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a LotteriesWithoutGroupsQuery
  def initialize
    @relation = LotteryAssignment
  end

  # Execute the lotteries without groups query.
  #
  # @param draw [Draw] the draw to restrict scope to.
  def call(draw:)
    @relation.where(draw: draw).includes(:groups)
             .where(groups: { lottery_assignment_id: nil })
  end
end
