# frozen_string_literal: true

# Service object to handle the starting of the lottery phase for a draw. Checks
# to make sure that the draw has the correct status and has enough beds for
# students, as well as no ungrouped students, and updates the status.
class DrawLotteryStarter
  include ActiveModel::Model
  include Callable

  attr_reader :draw

  validate :draw_in_pre_lottery_phase, if: ->() { draw.present? }
  validate :at_least_one_group, if: ->() { draw.present? }
  validate :all_students_grouped, if: ->() { draw.present? }
  validate :all_intents_declared, if: ->() { draw.present? }
  validate :enough_beds, if: ->() { draw.present? }
  validate :no_contested_suites, if: ->() { draw.present? }
  validate :all_groups_locked, if: ->() { draw.present? }
  validate :suite_sizes_available, if: ->() { draw.present? }

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
    return error(self) unless valid?
    destroy_unconfirmed_clip_invites
    draw.update!(status: 'lottery', intent_locked: true)
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :start

  private

  attr_writer :draw

  def draw_in_pre_lottery_phase
    return if draw.pre_lottery?
    errors.add(:draw, 'must be in the pre-lottery phase')
  end

  def at_least_one_group
    return if draw.groups?
    errors.add(:draw, 'must have at least one group')
  end

  def all_students_grouped
    return if draw.all_students_grouped?
    errors.add(:draw, 'cannot have any students not in groups')
  end

  def all_intents_declared
    return if draw.all_intents_declared?
    errors.add(:draw, 'cannot have any students who did not declare intent')
  end

  def enough_beds
    return if draw.enough_beds?
    errors.add(:draw, 'must have at least one bed per student in all suites')
  end

  def no_contested_suites
    return if draw.no_contested_suites?
    errors.add(:draw,
               'cannot contain any suites in other draws that are in the '\
               'lottery or suite selection phase')
  end

  def all_groups_locked
    return if draw.all_groups_locked?
    errors.add(:draw, 'cannot have any unlocked groups')
  end

  def suite_sizes_available
    diff = draw.group_sizes - draw.suite_sizes
    return if diff.empty?
    draw.groups.where(size: diff).destroy_all
    errors.add(:draw, 'all groups must be the size of an available suite. The'\
                      ' affected groups have been disbanded and must regroup.')
  end

  def destroy_unconfirmed_clip_invites
    UnconfirmedClipMembershipsForDrawQuery.call(draw: draw).destroy_all
  end

  def success
    { redirect_object: draw,
      msg: { success: 'You can now assign lottery numbers' } }
  end

  def error(error_obj)
    error_msgs = ErrorHandler.format(error_object: error_obj)
    msg = "There was a problem proceeding to the lottery phase:\n#{error_msgs}"
    { redirect_object: nil, msg: { error: msg } }
  end
end
