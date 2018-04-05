# frozen_string_literal: true

# Service object to handle the starting of the suite selection phase for a draw.
# Checks to make sure that the draw is in the correct phase and that the lottery
# is complete. Notifies the first groups for suite selection.
class DrawSelectionStarter
  include ActiveModel::Model
  include Callable

  validate :draw_in_lottery_phase
  validate :lottery_complete

  # Initialize a new DrawSelectionStarter
  #
  # @param draw [Draw] the draw in question
  def initialize(draw:, mailer: StudentMailer)
    @draw = draw
    @mailer = mailer
    @college = College.current
  end

  # Start the suite selection phase of a Draw and notify the first group(s) to
  # select
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the modified object.
  def start
    return error(self) unless valid?
    run!
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :start

  # Start the suite selection phase of a Draw and notify the first group(s) to
  # select. Same as #start, but does not rescue internal exceptions.
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the modified object.
  def start!
    validate!
    run!
  end

  make_callable :start!

  private

  attr_reader :mailer, :college
  attr_accessor :draw

  def run!
    destroy_invalid_lotteries
    draw.update!(status: 'suite_selection')
    notify_all_students
    notify_first_groups
    success
  end

  def draw_in_lottery_phase
    return if draw.nil? || draw.lottery?
    errors.add(:draw, 'must be in the lottery phase')
  end

  def lottery_complete
    return if draw.nil? || draw.lottery_complete?
    errors.add(:base, 'All groups must have lottery numbers assigned')
  end

  def notify_all_students
    students = draw.students.on_campus
    students.each do |s|
      mailer.lottery_notification(user: s, college: college).deliver_later
    end
  end

  def notify_first_groups
    draw.notify_next_groups(mailer)
  end

  def destroy_invalid_lotteries
    LotteriesWithoutGroupsQuery.call(draw: draw).destroy_all
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
