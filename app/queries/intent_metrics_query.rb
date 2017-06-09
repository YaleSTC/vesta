# frozen_string_literal: true

# Query to return the metrics on the intent selections of the students in a
# specific draw.
class IntentMetricsQuery
  # This is used to allow us to execute this query with the default base
  # relation without explicitly intantiating a new instance. It is often used to
  # more easily use query objects as model scopes, e.g.
  #   scope :intent_metrics, IntentMetricsQuery
  # instead of
  #   scope :intent_metrics, IntentMetricsQuery.new
  class << self
    delegate :call, to: :new
  end

  # Initialize an IntentMetricsQuery
  #
  # @param relation [User::ActiveRecord_Relation] the base relation for the
  #   metrics query
  def initialize(relation = User.all)
    @relation = relation
  end

  # Execute the metrics query
  #
  # @param draw [Draw] the draw to collect metrics for
  # @return [Hash{String => Integer}] a hash with intent Enum strings as keys
  #   and associated record counts as values
  def call(draw)
    @query_results = @relation.where(draw: draw).group(:intent).count.tap do |q|
      q.default = 0
    end
  end
end
