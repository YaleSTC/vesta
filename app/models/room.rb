# frozen_string_literal: true
#
# Model to represent the lowest-level of facility information
#
# @attr [String] number The identifier of the room. Must be unique
#   within a Suite.
# @attr [Integer] beds The number of beds within the room.
#   For common rooms, this is 0.
# @attr [Suite] suite belongs_to association for the Suite that the room is in.
class Room < ApplicationRecord
  belongs_to :suite

  validates :suite, presence: true
  validates :number, presence: true, allow_blank: false,
                     uniqueness: { scope: :suite }
  validates :beds, presence: true,
                   numericality: { only_integer: true,
                                   greater_than_or_equal_to: 0 }

  # Suite Size Counter Cache
  after_save :update_suite_size, if: :beds_changed?
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

  private

  def bedroom_type
    if beds > 2
      'multiple'
    else
      beds > 1 ? 'double' : 'single'
    end
  end

  def update_suite_size
    delta = beds - beds_was
    suite.increment(:size, delta)
  end

  def decrement_suite_size
    suite.decrement(:size, beds)
  end
end
