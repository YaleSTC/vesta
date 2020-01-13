# frozen_string_literal: true

# Query to return users with specific intent or intents.
class StudentsWithIntentQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a StudentsWithIntentQuery
  #
  # @param relation [User::ActiveRecord_Relation] the base relation for the
  #   query
  def initialize(relation = User.active)
    @relation = relation
  end

  # Execute the intents query
  #
  # @param intents [Array<String>] specified intents to query for
  # @return [Array<User>] the users in the relation gathered by
  #   specified intent
  def call(intents:)
    @relation.joins(:draw_membership)
             .where(draw_memberships: { intent: intents })
  end
end
