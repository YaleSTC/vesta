# frozen_string_literal: true

# Query to return unconfirmed clip memberships for a given draw
class UnconfirmedClipMembershipsForDrawQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize an UnconfirmedClipMembershipsForDrawQuery
  def initialize
    @relation = ClipMembership.all
  end

  # Execute the unconfirmed clip memberships query
  #
  # @param draw [Draw] the draw to restrict scope to.
  # @return [ClipMembership::ActiveRecord_Relation] unconfirmed clip_memberships
  def call(draw:)
    @relation.includes(:clip).where(confirmed: false,
                                    clips: { draw_id: draw.id })
  end
end
