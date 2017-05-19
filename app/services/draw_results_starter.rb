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
  def initialize(draw:, mailer: StudentMailer)
    @draw = draw
    @mailer = mailer
    @college = College.first
  end

  # Start the results phase of a Draw and create a duplicate draw if necessary
  # for ungrouped students
  #
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the modified object.
  def start
    return error unless valid?
    @new_draw = ActiveRecord::Base.transaction do
      draw.update!(status: 'results')
      next nil if draw.all_students_grouped?
      duplicate_draw
    end
    success
  rescue ActiveRecord::ActiveRecordError => e
    errors.add(:base, "Draw update failed: #{e.message}")
    error
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
  def duplicate_draw # rubocop:disable AbcSize
    d = Draw.create!(name: draw.name + ' (oversub)', status: 'pre_lottery')
    draw.ungrouped_students.each do |s|
      s.remove_draw.update!(draw_id: d.id, intent: 'on_campus')
    end
    d.suites << draw.suites.available
  end

  def success
    msg = if new_draw
            success_msg.merge(secondary_draw_warning)
          else
            success_msg
          end
    { redirect_object: draw, msg: msg }
  end

  def success_msg
    { success: 'All groups have suites!' }
  end

  def secondary_draw_warning
    { notice: 'A new draw has been created with all ungrouped students.' }
  end

  def error
    msg = "There was a problem completing suite selection:\n#{error_msgs}"
    { redirect_object: nil, msg: { error: msg } }
  end

  def error_msgs
    errors.full_messages.join(', ')
  end
end
