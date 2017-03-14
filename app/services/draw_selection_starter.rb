# frozen_string_literal: true
#
# Service object to handle the starting of the lottery phase for a draw. Checks
# to make sure that the draw has the correct status and has enough beds for
# students, as well as no ungrouped students, and updates the status.
class DrawSelectionStarter
  include ActiveModel::Model

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
  def initialize(draw:, mailer: StudentMailer)
    @draw = draw
    @mailer = mailer
  end

  # Start the suite selection phase of a Draw and notify the first group(s) to
  # select
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the modified object.
  def start
    return error unless valid?
    if draw.update(status: 'suite_selection')
      notify_first_groups
      return success
    else
      errors.add(:base, 'Draw update failed')
      error
    end
  end

  private

  attr_reader :mailer
  attr_accessor :draw

  def draw_in_lottery_phase
    return if draw.nil? || draw.lottery?
    errors.add(:draw, 'must be in the lottery phase')
  end

  def lottery_complete
    return if draw.nil? || draw.lottery_complete?
    errors.add(:base, 'All groups must have lottery numbers assigned')
  end

  def notify_first_groups
    draw.notify_next_groups(mailer)
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
