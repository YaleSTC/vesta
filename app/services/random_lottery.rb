# frozen_string_literal: true

require 'securerandom'

# Service Object to assign random lottery numbers in a draw
class RandomLottery
  include ActiveModel::Model
  include Callable

  validate :draw_in_lottery

  # Initialize a new RandomLottery
  #
  # @param draw [Draw] the draw to assign lottery numbers in
  def initialize(draw:)
    @draw = draw
  end

  # Assign random lottery numbers and start the suite selection phase
  # of the draw
  #
  # @return [Hash{Symbol=>Draw,Hash}] A results hash with the message to set
  #   in the flash and the draw to redirect to
  def run # rubocop:disable Metrics/MethodLength
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      lottery!
      DrawSelectionStarter.start!(draw: draw)
    end
    success
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid => e
    error(e)
  rescue ActiveModel::ValidationError => e
    # This catches errors from service objects used within this one
    errors.add(:base, e.message)
    error(self)
  end

  make_callable :run

  private

  attr_reader :draw

  def draw_in_lottery
    return if draw.lottery?
    errors.add(:base, 'draw must be in lottery')
  end

  def lottery!
    draw.lottery_assignments.each(&:destroy!)
    lottery_assignments = ObjectsForLotteryQuery.call(draw: draw)
    order = (1..lottery_assignments.count).to_a.shuffle(random: SecureRandom)
    lottery_assignments.each_with_index do |l, i|
      l.number = order[i]
      l.save!
    end
  end

  def success
    {
      redirect_object: draw,
      msg: { success: 'Lottery numbers assigned and suite selection started' }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      redirect_object: draw,
      msg: { error: "Random lottery failed: #{msg}" }
    }
  end
end
