# frozen_string_literal: true

# Model to represent the highest-level of facility information
# A building is composed of mulitple suites, which in turn have multiple rooms
#
# @attr [String] full_name The full name of the building. Must be unique.
# @attr [String] abbreviation The abbreviation of the building. Can be nil.
# @attr [Array<Suite>] suites has_many association of Suites in the Building.
class Building < ApplicationRecord
  has_many :suites, dependent: :destroy

  validates :full_name, presence: true, allow_blank: false, uniqueness: true
  validates :abbreviation, uniqueness: true, allow_nil: true

  def name
    abbreviation ? abbreviation : full_name
  end

  def suites_by_size
    suites.order(:size).group_by(&:size)
  end
end
