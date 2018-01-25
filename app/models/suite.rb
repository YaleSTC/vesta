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
                8 => 'octet', 0 => 'empty' }.freeze
  belongs_to :building
  belongs_to :group
  has_many :rooms, dependent: :nullify
  has_many :draw_suites, dependent: :delete_all
  has_many :draws, through: :draw_suites

  validates :building, presence: true
  validates :number, presence: true, uniqueness: { scope: :building }
  validates :size, presence: true,
                   numericality: { greater_than_or_equal_to: 0 }

  scope :available, -> { where(group_id: nil) }

  before_save :remove_room_assignments,
              if: ->() { will_save_change_to_group_id? }
  before_save :remove_draw_from_medical_suites,
              if: ->() { will_save_change_to_medical? }
  after_save :update_lottery_assignment, if: ->() { saved_change_to_group_id? }

  # Return the equivalent string for a given suite size
  #
  # @param size [Integer] the suite size
  # @return [String] the equivalnet string
  def self.size_str(size)
    raise ArgumentError unless size.is_a?(Integer) && size >= 0
    return SIZE_STRS[size] if SIZE_STRS.key? size
    "#{size}-pack"
  end

  # Return the building name with the suite number
  #
  # @return [String] the building name with the suite number
  def name
    "#{building.name} #{number}"
  end

  # Return the building name with the suite number and the medical status
  #
  # @return [String] the building name with the suite number and medical status
  def name_with_medical
    return name unless medical
    "#{name} (medical)"
  end

  # Return the name of the suite with the names of any draws it belongs to.
  # Optionally excludes a single draw passed in.
  #
  # @param [Draw] the draw to exclude
  # @return [String] the suite name with draw names
  def name_with_draws(draw = nil)
    return name if draws.empty?
    draws_to_display = draws.where.not(id: draw&.id)
    return name if draws_to_display.empty?
    draws_str = draws_to_display.map(&:name).join(', ')
    "#{name} (#{draws_str})"
  end

  # Return whether or not a suite is available
  #
  # @return [Boolean] whether or not the suite is available
  def available?
    group_id.nil?
  end

  # Return all single-bed rooms in the suite
  #
  # @return [Room::ActiveRecord_AssociationRelation] relation for all of the
  #   rooms with 1 bed
  def singles
    rooms.select { |r| r.beds == 1 }
  end

  # Return all double-bed rooms in the suite
  #
  # @return [Room::ActiveRecord_AssociationRelation] relation for all of the
  #   rooms with 2 bed
  def doubles
    rooms.select { |r| r.beds == 2 }
  end

  # Return all common rooms in the suite
  #
  # @return [Room::ActiveRecord_AssociationRelation] relation for all of the
  #   common rooms
  def common_rooms
    rooms.select { |r| r.beds.zero? }
  end

  # Return whether or not a suite can be selected in a new draw (e.g. it is not
  # currently in any draw that is in the lottery or suite_selection phase)
  #
  # @return [Boolean] whether or not the suite is selectable
  def selectable?
    draws.all? { |draw| !(draw.lottery? || draw.suite_selection?) }
  end

  # Return the suite number, indicating if the suite is a medical suite or not
  #
  # @return [String] the number with medical status indicated
  def number_with_medical
    return number unless medical
    "#{number} (medical)"
  end

  private

  def remove_room_assignments
    rooms.map(&:room_assignments).map(&:destroy_all)
  rescue
    throw(:abort)
  end

  def remove_draw_from_medical_suites
    return unless medical
    ActiveRecord::Base.transaction { draws.delete_all }
  rescue
    throw(:abort)
  end

  def update_lottery_assignment
    g_id = saved_change_to_group_id.compact.first
    lottery = Group.includes(:lottery_assignment).find(g_id).lottery_assignment
    return unless lottery
    lottery.update_selected!
  end
end
