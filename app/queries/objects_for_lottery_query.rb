# frozen_string_literal: true

# Query to return the groups and clips ready for lottery
class ObjectsForLotteryQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a ObjectsForLotteryQuery
  def initialize
    @relation = LotteryBaseView.includes(
      [group: :leader], [clip: [clip_memberships: [group: :leader]]]
    )
  end

  # Execute the groups for lottery query.
  #
  # @param draw [Draw] The draw to restrict scope to.
  # @return [Array<LotteryAssignment>] An array of lottery assignment objects.
  def call(draw:)
    @relation.where(draw: draw).map(&:to_lottery)
             .sort_by { |result| result.leader.last_name }
  end
end
