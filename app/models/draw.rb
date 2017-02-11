# frozen_string_literal: true
#
# Model to represent Housing Draws.
#
# @attr name [String] The name of the housing draw -- e.g. "Junior Draw 2016"
# @attr students [Array<User>] The students in the draw.
# @attr suites [Array<Suite>] The suites in the draw.
# @attr status [String] The status / phase of the draw (draft, pre_lottery,
#   TODO: lottery, post_lottery). Note the use of underscores in the status
#   strings; this prevents some unpleasantness with the helper methods.
class Draw < ApplicationRecord
  has_many :groups
  has_many :students, class_name: 'User'
  has_many :draws_suites, dependent: :delete_all
  has_many :suites, through: :draws_suites

  validates :name, presence: true
  validates :status, presence: true

  enum status: %w(draft pre_lottery)

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

  private

  def student_count
    @student_count ||= students.count
  end

  # Calculate the number of beds that exist across all available suites
  #
  # @return [Integer] the number of beds in all available suites
  def bed_count
    @bed_count ||= suites.available.sum(:size)
  end
end
