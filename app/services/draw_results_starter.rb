# frozen_string_literal: true

# Service object to handle the starting of the results phase for a draw. Checks
# to make sure that the draw has the correct status and has enough beds for
# students, as well as no ungrouped students, and updates the status.
class DrawResultsStarter
  include ActiveModel::Model
  include Callable

  # validates :draw, presence: :true
  validate :draw_in_selection_phase
  validate :no_more_suiteless_groups

  # Initialize a new DrawResultsStarter
  #
  # @param draw [Draw] the draw in question
  def initialize(draw:)
    @draw = draw
  end

  # Start the results phase of a Draw and create a duplicate draw if necessary
  # for ungrouped students
  #
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the modified object.
  def start
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      draw.update!(status: 'results')
      @new_draw = draw.all_students_grouped? ? false : duplicate_draw!
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :start

  private

  attr_reader :new_draw
  attr_accessor :draw

  def draw_in_selection_phase
    return if draw.nil? || draw.suite_selection?
    errors.add(:draw, 'must be in the selection phase')
  end

  def no_more_suiteless_groups
    return if draw.nil? || draw.all_groups_have_suites?
    errors.add(:base, 'All groups must have suites selected')
  end

  # Note: this occurs in a transaction
  def duplicate_draw! # rubocop:disable AbcSize
    d = Draw.create!(name: draw.name + ' (oversub)', status: 'pre_lottery')
    draw.ungrouped_students.each do |s|
      s.remove_draw.update!(draw_id: d.id, intent: 'on_campus')
    end
    d.suites << draw.suites.available
    true
  end

  def success
    msg = success_msg
    msg.merge!(secondary_draw_warning) if new_draw
    { redirect_object: draw, msg: msg }
  end

  def success_msg
    { success: 'All groups have suites!' }
  end

  def secondary_draw_warning
    { notice: 'A new draw has been created with all ungrouped students.' }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: nil,
      msg: { error: "There was a problem completing suite selection: #{msg}" } }
  end
end
