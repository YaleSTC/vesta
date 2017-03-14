# frozen_string_literal: true
#
# Model to represent Housing Draws.
#
# @attr name [String] The name of the housing draw -- e.g. "Junior Draw 2016"
# @attr students [Array<User>] The students in the draw.
# @attr suites [Array<Suite>] The suites in the draw.
# @attr status [String] The status / phase of the draw (draft, pre_lottery,
#   lottery, suite_selection). Note the use of underscores in the status
#   strings; this prevents some unpleasantness with the helper methods.
# @attr locked_sizes [Array<Integer>] the group sizes that are restricted.
# @attr intent_locked [Boolean] True when students in the draw can no longer
#   update their housing intent.
class Draw < ApplicationRecord
  has_many :groups
  has_many :students, class_name: 'User', dependent: :nullify
  has_many :draws_suites, dependent: :delete_all
  has_many :suites, through: :draws_suites

  validates :name, presence: true
  validates :status, presence: true

  validate :cannot_lock_intent_if_undeclared,
           if: ->() { intent_locked_changed? }

  after_destroy :remove_old_draw_ids

  enum status: %w(draft pre_lottery lottery suite_selection)

  # Finds all available suite sizes within a draw
  #
  # @return [Array<Integer>] the available suite sizes
  def suite_sizes
    SuiteSizesQuery.new(suites.available).call
  end

  # Finds the sizes that groups exist for within the draw
  #
  # @return [Array<Integer>] the available group sizes
  def group_sizes
    @group_sizes ||= GroupSizesQuery.new(groups).call
  end

  # Finds all suite sizes for which new groups can be created by removing
  # locked_sizes from available sizes
  #
  # @return [Array<Integer>] the suite sizes for which new groups can be created
  def open_suite_sizes
    suite_sizes - locked_sizes
  end

  # Query method get the suites without groups in the draw
  #
  # @return [ActiveRecord::Relation] the suites without assigned groups
  def available_suites
    suites.available
  end

  # Query method to see if a draw has at least one student.
  #
  # @return [Boolean] whether or not the draw has at least one student
  def students?
    student_count.positive?
  end

  # Query method to see if a draw has enough beds for its students.
  #
  # @return [Boolean] whether or not the draw has as many or more beds than it
  #   has students
  def enough_beds?
    bed_count >= student_count
  end

  # Query method to see if a draw has at least one group.
  #
  # @return [Boolean] whether or not the draw has at least one group
  def groups?
    group_count.positive?
  end

  # Query method to see if all on-campus students in the draw are in groups
  #
  # @return [Boolean] whether or not all on-campus students are in groups
  def all_students_grouped?
    @grouped_query ||= UngroupedStudentsQuery.new(
      students.where(intent: %w(undeclared on_campus))
    ).call.count.zero?
  end

  # Query method to see if there are no undeclared students in the draw
  #
  # @return [Boolean] whether or not the draw has no undeclared students
  def all_intents_declared?
    @undeclared_count ||= students.undeclared.count
    @undeclared_count.zero?
  end

  # Query method to see if all the groups in the draw are locked
  #
  # @return [Boolean] whether or not all the groups are locked
  def all_groups_locked?
    groups.all?(&:locked?)
  end

  # Query method to check if all suites are uncontested in other draws
  #
  # @return [Boolean] whether or not all suites are uncontested
  def no_contested_suites?
    suites.includes(:draws).available.all?(&:selectable?)
  end

  def student_count
    @student_count ||= students.count
  end

  # calculate the number of beds that exist across all available suites
  #
  # @return [integer] the number of beds in all available suites
  def bed_count
    @bed_count ||= suites.available.sum(:size)
  end

  # Query method to check whether or not a draw is not yet in the lottery phase
  #
  # @return [Boolean] whether or not the draw is not yet in the lottery phase
  def before_lottery?
    %w(draft pre_lottery).include? status
  end

  # Query method to return whether or not all groups have lottery numbers
  # assigned
  #
  # @return [Boolean] whether or not all groups have lottery numbers
  # assigned
  def lottery_complete?
    groups.all? { |g| g.lottery_number.present? }
  end

  # Query method to check whether or not a draw is oversubscribed by checking
  # all groups. Memoized to avoid querying multiple times per request.
  #
  # @return [Boolean] whether or not the draw is oversubscribed
  def oversubscribed?
    @oversubscribed ||= group_sizes.any? do |size|
      groups.where(size: size).count > suites.where(size: size).count
    end
  end

  # Query method to check whether or not a given group size is locked
  #
  # @param [Integer] the group size to check
  # @return [Boolean] whether or not the group size is locked
  def size_locked?(size)
    locked_sizes.include? size
  end

  # Return the next groups to select suites by lottery number. Returns an empty
  # array if no groups without suites and with lottery numbers exist.
  #
  # @return [Array<Group>] the next available groups using NextGroupsQuery
  def next_groups
    NextGroupsQuery.call(draw: self)
  end

  private

  def group_count
    @group_count ||= groups.count
  end

  def remove_old_draw_ids
    User.where(old_draw_id: id).update_all(old_draw_id: nil)
  end

  def cannot_lock_intent_if_undeclared
    return if all_intents_declared?
    errors.add :intent_locked, 'Cannot lock intent with undeclared students'
  end
end
