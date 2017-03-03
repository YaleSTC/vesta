# frozen_string_literal: true
#
# Model to represent Housing Draws.
#
# @attr name [String] The name of the housing draw -- e.g. "Junior Draw 2016"
# @attr students [Array<User>] The students in the draw.
# @attr suites [Array<Suite>] The suites in the draw.
# @attr status [String] The status / phase of the draw (draft, pre_lottery,
#   lottery, post_lottery). Note the use of underscores in the status strings;
#   this prevents some unpleasantness with the helper methods.
class Draw < ApplicationRecord
  has_many :groups
  has_many :students, class_name: 'User', dependent: :nullify
  has_many :draws_suites, dependent: :delete_all
  has_many :suites, through: :draws_suites

  validates :name, presence: true
  validates :status, presence: true

  after_destroy :remove_old_draw_ids

  enum status: %w(draft pre_lottery lottery suite_selection)

  # Finds all available suite sizes within a draw
  #
  # @return [Array<Integer>] the available suite sizes
  def suite_sizes
    SuiteSizesQuery.new(suites.available).call
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

  # Query method to see if a draw has any students not in group
  #
  # @return [Boolean] whether or not there are any ungrouped students
  def ungrouped_students?
    students.includes(:group).select { |s| s.group.nil? }.count.positive?
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

  private

  def group_count
    @group_count ||= groups.count
  end

  def remove_old_draw_ids
    User.where(old_draw_id: id).update_all(old_draw_id: nil)
  end
end
