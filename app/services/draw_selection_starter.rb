# frozen_string_literal: true
#
# Service object to handle the starting of the lottery phase for a draw. Checks
# to make sure that the draw has the correct status and has enough beds for
# students, as well as no ungrouped students, and updates the status.
class DrawSelectionStarter
  include ActiveModel::Model

  attr_reader :draw

  # validates :draw, presence: :true
  validate :draw_in_lottery_phase
  validate :lottery_complete

  # Class method to permit calling :start on the class without instantiating the
  # service object directly
  def self.start(**params)
    new(**params).start
  end

  # Initialize a new DrawSelectionStarter
  #
  # @param draw [Draw] the draw in question
  def initialize(draw:)
    @draw = draw
  end

  # Start the lottery phase of a Draw
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the modified object.
  def start
    return error unless valid?
    return success if draw.update(status: 'suite_selection')
    errors.add(:base, 'Draw update failed')
    error
  end

  private

  attr_writer :draw

  def draw_in_lottery_phase
    return if draw.nil? || draw.lottery?
    errors.add(:draw, 'must be in the lottery phase')
  end

  def lottery_complete
    return if draw.nil? || draw.lottery_complete?
    errors.add(:base, 'All groups must have lottery numbers assigned')
  end

  def success
    { object: draw, msg: { success: 'Suite selection started' } }
  end

  def error
    msg = "There was a problem starting suite selection:\n#{error_msgs}"
    { object: nil, msg: { error: msg } }
  end

  def error_msgs
    errors.full_messages.join(', ')
  end
end
