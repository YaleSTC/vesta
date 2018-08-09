# frozen_string_literal: true

# Query to return users grouped by their intent.
class UsersByIntentQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a UsersByIntentQuery
  #
  # @param relation [User::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = User.active)
    @relation = relation
  end

  # Execute the intents query
  #
  # @return [Hash{String=>Array<User>}] the users in the relation gathered by
  #   intent
  def call
    @relation.includes(:draw_membership)
             .order('draw_memberships.intent', :last_name)
             .group_by { |s| s.draw_membership.intent }
  end
end
