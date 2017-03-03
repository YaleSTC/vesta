# frozen_string_literal: true
#
# Service object to handle the starting of the lottery phase for a draw. Checks
# to make sure that the draw has the correct status and has enough beds for
# students, as well as no ungrouped students, and updates the status.
class DrawLotteryStarter
  include ActiveModel::Model

  attr_reader :draw

  # validates :draw, presence: :true
  validate :draw_in_pre_lottery_phase
  validate :at_least_one_group
  validate :no_ungrouped_students
  validate :enough_beds
  validate :no_contested_suites
  validate :all_groups_locked

  # Class method to permit calling :start on the class without instantiating the
  # service object directly
  def self.start(**params)
    new(**params).start
  end

  # Initialize a new DrawLotteryStarter
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
    return success if draw.update(status: 'lottery')
    errors.add(:base, 'Draw update failed')
    error
  end

  private

  attr_writer :draw

  def draw_in_pre_lottery_phase
    return if draw.nil? || draw.pre_lottery?
    errors.add(:draw, 'must be in the pre-lottery phase')
  end

  def at_least_one_group
    return if draw.nil? || draw.groups?
    errors.add(:draw, 'must have at least one group')
  end

  def no_ungrouped_students
    return unless draw.present? && draw.ungrouped_students?
    errors.add(:draw, 'cannot have any students not in groups')
  end

  def enough_beds
    return if draw.nil? || draw.enough_beds?
    errors.add(:draw, 'must have at least one bed per student in all suites')
  end

  def no_contested_suites
    return if draw.nil? || draw.no_contested_suites?
    errors.add(:draw,
               'cannot contain any suites in other draws that are in the '\
               'lottery or suite selection phase')
  end

  def all_groups_locked
    return if draw.nil? || draw.all_groups_locked?
    errors.add(:draw, 'cannot have any unlocked groups')
  end

  def success
    { object: draw, msg: { success: 'You can now assign lottery numbers' } }
  end

  def error
    msg = "There was a problem proceeding to the lottery phase:\n#{error_msgs}"
    { object: nil, msg: { error: msg } }
  end

  def error_msgs
    errors.full_messages.join(', ')
  end
end
