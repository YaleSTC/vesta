# frozen_string_literal: true
#
# Model to represent Housing Draws.
#
# @attr [String] name The name of the housing draw -- e.g. "Junior Draw 2016"
# @attr [Array<User>] students The students in the draw.
# @attr [Array<Suite>] suites The suites in the draw.
class Draw < ApplicationRecord
  has_many :students, class_name: 'User'
  has_and_belongs_to_many :suites # rubocop:disable Rails/HasAndBelongsToMany

  validates :name, presence: true

  def suite_sizes
    suites.map(&:size).uniq
  end
end
