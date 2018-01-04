# frozen_string_literal: true

# Presenter object for reporting things about a collection of Groups
# Delegates to that collection
class GroupsReport < SimpleDelegator
  # Sorts the group collection by status and groups by size
  #
  # @return [Hash{Integer => Array<Group>}] A hash mapping group sizes to an
  #   array of all groups of that size in the collection, sorted by status
  def by_size
    @by_size ||= sort_by { |g| Group.statuses[g.status] }.group_by(&:size)
    @by_size.default = []
    @by_size
  end

  # Gets the groups in the collection with suites
  #
  # @return [ActiveRecord::Associations::CollectionProxy] The groups with suites
  def with_suites
    @with_suites ||= joins(:suite)
  end

  # Gets number of groups in the collection with suites
  #
  # @return [Integer] The number of groups with suites
  def with_suites_count
    @with_suite_count ||= with_suites.count
  end

  # Gets number of groups in the collection with suites but without rooms chosen
  #
  # @return [Integer] The number of groups with suites but without rooms
  def without_rooms_count
    @no_room_count ||= with_suites_count -
                       with_suites.joins(leader: :room).count
  end

  # Gets the groups in the collection without suites, sorted by lottery number
  #
  # @return [ActiveRecord::Associations::CollectionProxy] The groups without
  #   suites, sorted by lottery number
  def without_suites
    @without_suites ||= order_by_lottery.includes(:suite)
                                        .where(suites: { group_id: nil })
  end

  # Gets the groups in the collection without suites, sorted by lottery number,
  #   and grouped by size
  #
  # @return [Hash{Integer => ActiveRecord::Associations::CollectionProxy}] A
  #   hash mapping group sizes to groups of that size without a suite selected,
  #   sorted by lottery number
  def without_suites_by_size
    @without_suites ||= without_suites.group_by(&:size)
    @without_suites.default = []
    @without_suites
  end

  # Gets number of groups in the collection without suites
  #
  # @return [Integer] The number of groups without suites
  def without_suites_count
    @no_suite_count = without_suites.count
  end
end
