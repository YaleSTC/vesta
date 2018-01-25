# frozen_string_literal: true

# Model to represent the lowest-level of facility information
#
# @attr [String] number The identifier of the room. Must be unique
#   within a Suite.
# @attr [Integer] beds The number of beds within the room.
#   For common rooms, this is 0.
# @attr [Suite] suite belongs_to association for the Suite that the room is in.
# @attr [String] original_suite The number of the original suite that the room
#   was in. Is an empty string unless the room belongs to a merged suite.
class Room < ApplicationRecord
  belongs_to :suite
  has_many :room_assignments, dependent: :destroy
  has_many :users, through: :room_assignments

  validates :suite, presence: true
  validates :number, presence: true, allow_blank: false,
                     uniqueness: { scope: :suite, case_sensitive: false }
  validates :beds, presence: true,
                   numericality: { only_integer: true,
                                   greater_than_or_equal_to: 0 }

  # Suite Size Counter Cache
  after_save :update_suite_size
  after_destroy :decrement_suite_size

  # Evaluates the room type.
  #
  # @return [String] The type of room (e.g. single, common, double)
  def type
    if beds.positive?
      bedroom_type
    else
      'common'
    end
  end

  # Gets a formatted string of the room number and it's type
  #
  # @return [String] e.g. L01A (double)
  def number_with_type
    "#{number} (#{type})"
  end

  # Sets original_suite to the current suite number, unless it is already set
  #
  # @params [Hash] attrs Other attributes to update
  #
  # @return [Boolean] Whether or not the update was successful
  def store_original_suite!(**attrs)
    attrs[:original_suite] = suite.number if original_suite.blank?
    update!(attrs)
  end

  private

  def bedroom_type
    if beds > 2
      'multiple'
    else
      beds > 1 ? 'double' : 'single'
    end
  end

  def update_suite_size
    return unless saved_change_to_beds || saved_change_to_suite_id
    update_suite_size_based_on_beds if saved_change_to_beds
    update_suite_size_based_on_assignment if saved_change_to_suite_id
  end

  # rubocop:disable Rails/SkipsModelValidations
  def update_suite_size_based_on_beds
    delta = beds - beds_before_last_save
    suite.increment!(:size, delta)
  end

  def update_suite_size_based_on_assignment
    # prevent double increment on creation
    return unless suite_id_before_last_save
    # use find_by in case of deletion / nullify callback
    old_suite = Suite.find_by(id: suite_id_before_last_save)
    new_suite = Suite.find_by(id: suite_id)
    old_suite&.decrement!(:size, beds_before_last_save)
    new_suite&.increment!(:size, beds)
  end

  def decrement_suite_size
    suite.decrement!(:size, beds)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
