# frozen_string_literal: true

# Query object to return all suites that have rooms assigned
class SuitesWithRoomsAssignedQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a SuitesWithRoomsAssignedQuery instance
  #
  # @param relation [Suite::ActiveRecord_Relation] base relation to use for the
  #   query object, defaults to all suites
  def initialize(relation = Suite.all)
    @relation = relation
  end

  # Execute the query
  #
  # @return [Suite::ActiveRecord_Relation] the suites for which rooms have been
  #   assigned, eager loads rooms and users
  def call
    @relation.includes(rooms: :users).where.not(users: { room_id: nil })
             .order(%w(suites.number rooms.number))
  end
end
