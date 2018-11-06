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
    @sort = College.current.size_sort
  end

  # Assign random lottery numbers and start the suite selection phase
  # of the draw
  #
  # @return [Hash{Symbol=>Draw,Hash}] A results hash with the message to set
  #   in the flash and the draw to redirect to
  def run # rubocop:disable Metrics/MethodLength
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      clear_and_set_lottery_assignments
      sort_lottery_assignments
      assign_lottery_values
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

  attr_reader :draw, :sort, :lottery_assignments

  def draw_in_lottery
    return if draw.lottery?
    errors.add(:base, 'draw must be in lottery')
  end

  def clear_and_set_lottery_assignments
    draw.lottery_assignments.each(&:destroy!)
    if sort == 'no_sort'
      @lottery_assignments = ObjectsForLotteryQuery.call(draw: draw)
    else
      @lottery_assignments = LotteriesBySizeQuery.call(draw: draw)
    end
  end

  def sort_lottery_assignments
    if sort == 'no_sort'
      @lottery_assignments.shuffle!(random: SecureRandom)
    else
      @lottery_assignments.transform_values! do |las|
        las.shuffle(random: SecureRandom)
      end
      keys = @lottery_assignments.keys.sort
      keys.reverse! if sort == 'descending'
      @lottery_assignments = lottery_assignments.values_at(*keys).flatten!
    end
  end

  def assign_lottery_values
    lottery_assignments.each_with_index do |l, i|
      l.update!(number: i + 1)
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
