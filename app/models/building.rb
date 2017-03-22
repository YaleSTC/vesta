# frozen_string_literal: true

# Model to represent the highest-level of facility information
# A building is composed of mulitple suites, which in turn have multiple rooms
#
# @attr [String] name The name of the building. Must be unique.
# @attr [Array<Suite>] suites has_many association of Suites in the Building.
class Building < ApplicationRecord
  has_many :suites, dependent: :destroy

  validates :name, presence: true, allow_blank: false, uniqueness: true

  def suites_by_size
    suites.order(:size).group_by(&:size)
  end
end
