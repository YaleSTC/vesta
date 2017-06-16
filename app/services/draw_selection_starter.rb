# frozen_string_literal: true

# Service object to handle the starting of the suite selection phase for a draw.
# Checks to make sure that the draw is in the correct phase and that the lottery
# is complete. Notifies the first groups for suite selection.
class DrawSelectionStarter
  include ActiveModel::Model
  include Callable

  # validates :draw, presence: :true
  validate :draw_in_lottery_phase
  validate :lottery_complete

  # Initialize a new DrawSelectionStarter
  #
  # @param draw [Draw] the draw in question
  def initialize(draw:, mailer: StudentMailer)
    @draw = draw
    @mailer = mailer
    @college = College.first
  end

  # Start the suite selection phase of a Draw and notify the first group(s) to
  # select
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the modified object.
  def start
    return error(self) unless valid?
    draw.update!(status: 'suite_selection')
    notify_first_groups
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :start

  private

  attr_reader :mailer, :college
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
    { redirect_object: draw, msg: { success: 'Suite selection started' } }
  end

  def error(error_obj)
    error_msgs = ErrorHandler.format(error_object: error_obj)
    msg = "There was a problem starting suite selection:\n#{error_msgs}"
    { redirect_object: nil, msg: { error: msg } }
  end
end
