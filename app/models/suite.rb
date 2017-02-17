# frozen_string_literal: true

# Model to represent the middle level of facility information
# A suite is composed of mulitple rooms, which can be bedrooms or common rooms
#
# @attr number [String] The identifier of the Suite. Must be unique for Suites
#   in the same Building.
# @attr size [Integer] Counter cache of the total number of beds within the
#   Suite's Rooms. Must be >= 0.
# @attr building [Building] belongs_to association for the Building the Suite is
#   located in.
# @attr rooms [Array<Room>] has_many association for the Rooms within the Suite.
# @attr active [Boolean] whether or not the suite is active
class Suite < ApplicationRecord
  SIZE_STRS = { 1 => 'single', 2 => 'double', 3 => 'triple', 4 => 'quadruple',
                5 => 'quintuple', 6 => 'sextuple', 7 => 'septuple',
                8 => 'octuple' }.freeze
  belongs_to :building
  belongs_to :group
  has_many :rooms
  has_many :draws_suites, dependent: :destroy
  has_many :draws, through: :draws_suites

  validates :building, presence: true
  validates :number, presence: true, uniqueness: { scope: :building }
  validates :size, presence: true,
                   numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :available, -> { where(group_id: nil).order(:number).active }

  # Return the equivalent string for a given suite size
  #
  # @param size [Integer] the suite size
  # @return [String] the equivalnet string
  def self.size_str(size)
    raise ArgumentError unless size.is_a?(Integer) && size.positive?
    return SIZE_STRS[size] if SIZE_STRS.key? size
    "#{size}-suite"
  end

  # Return the number of the suite with the names of any draws it belongs to.
  # Optionally excludes a single draw passed in.
  #
  # @param [Draw] the draw to exclude
  # @return [String] the suite number with draw names
  def number_with_draws(draw = nil)
    return number if draws.empty?
    draws_to_display = draws.where.not(id: draw.try(:id))
    return number if draws_to_display.empty?
    draws_str = draws_to_display.map(&:name).join(', ')
    "#{number} (#{draws_str})"
  end

  # Deactivate a suite (unpersisted).
  #
  # @return [Suite] the potentially deactivated suite
  def deactivate
    assign_attributes(active: false)
    self
  end

  # Activate a suite (unpersisted).
  #
  # @return [Suite] the potentially activated suite
  def activate
    assign_attributes(active: true)
    self
  end
end
