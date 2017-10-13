# frozen_string_literal: true
# frozen_string_literal: true

# Query to return all of the group and available suite sizes for a given draw.
# Defaults to drawless groups if no draw passed.
class DrawSizesQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a new DrawSizesQuery, loads all arel tables as instance variables
  def initialize
    @draws = Draw.arel_table
    @draw_suites = DrawSuite.arel_table
    @groups = Group.arel_table
    @suites = Suite.arel_table
  end

  # Execute the draw sizes query, now with 100% more Arel!
  #
  # @param draw [Draw] the draw to collect sizes for, if nil collects draws
  # @return [Array<Integer>] the group and available suite sizes in the relation
  def call(draw: nil)
    suite_base = draw ? draw_suite_base(draw) : global_suite_base
    suite_query = suite_base.project(suites[:size]).distinct
    overall_query = suite_query.union(group_query(draw))
    ActiveRecord::Base.connection.select_values(overall_query.to_sql).sort
  end

  private

  attr_reader :draws, :draw_suites, :groups, :suites

  def draw_suite_base(draw) # rubocop:disable AbcSize
    suites.join(draw_suites)
          .on(draw_suites[:suite_id].eq(suites[:id]))
          .where(draw_suites[:draw_id].eq(draw.id))
          .where(available_suite)
  end

  def global_suite_base
    suites.where(available_suite)
  end

  def available_suite
    suites[:group_id].eq(nil)
  end

  def group_query(draw) # rubocop:disable AbcSize
    groups.join(suites, Arel::Nodes::OuterJoin)
          .on(suites[:group_id].eq(groups[:id]))
          .where(groups[:draw_id].eq(draw&.id))
          .where(available_suite)
          .project(groups[:size])
          .distinct
  end
end
