# frozen_string_literal: true

# Model to represent the middle level of facility information
# A suite is composed of mulitple rooms, which can be bedrooms or common rooms
#
# @attr [String] number The identifier of the Suite. Must be unique
#   for Suites in the same Building.
# @attr [Integer] size Counter cache of the total number of beds
#   within the Suite's Rooms. Must be >= 0.
# @attr [Building] building belongs_to association for the Building the
#   Suite is located in.
# @attr [Array<Room>] rooms has_many association for the Rooms within the Suite.
class Suite < ApplicationRecord
  SIZE_STRS = { 1 => 'single', 2 => 'double', 3 => 'triple', 4 => 'quad',
                5 => 'quint', 6 => 'sextet', 7 => 'septet',
                8 => 'octet' }.freeze
  belongs_to :building
  belongs_to :group
  has_many :rooms
  has_and_belongs_to_many :draws # rubocop:disable Rails/HasAndBelongsToMany

  validates :building, presence: true
  validates :number, presence: true, uniqueness: { scope: :building }
  validates :size, presence: true,
                   numericality: { greater_than_or_equal_to: 0 }

  scope :available, -> { where(group_id: nil) }

  # Return the equivalent string for a given suite size
  #
  # @param size [Integer] the suite size
  # @return [String] the equivalnet string
  def self.size_str(size)
    raise ArgumentError unless size.is_a?(Integer) && size.positive?
    return SIZE_STRS[size] if SIZE_STRS.key? size
    "#{size}-Pack"
  end
end
