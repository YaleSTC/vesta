# frozen_string_literal: true

# Query to return the groups available to clip
class GroupsForClippingQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a GroupsForClippingQuery
  #
  # @param relation [Group::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = Group.all)
    @relation = relation
  end

  # Execute the groups for clipping query.
  #
  # @param draw [Draw] the draw to restrict scope to.
  # @param group [Group] a group to exclude from the query, if any.
  # @return [Group::ActiveRecord_Relation] the groups available to clip.
  def call(draw:, group: nil)
    @relation.includes(:clip_membership, :leader).where.not(id: group&.id)
             .where(draw: draw, clip_memberships: { id: nil })
             .order('users.last_name')
  end
end
