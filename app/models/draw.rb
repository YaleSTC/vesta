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
  has_many :students, class_name: 'User'
  has_and_belongs_to_many :suites # rubocop:disable Rails/HasAndBelongsToMany

  validates :name, presence: true
  validates :status, presence: true

  enum status: %w(draft pre_lottery)

  def suite_sizes
    suites.map(&:size).uniq
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

  def bed_count
    @bed_count ||= suites.sum(:size)
  end
end
