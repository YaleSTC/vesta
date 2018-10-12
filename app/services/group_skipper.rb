# frozen_string_literal: true

# Service object to update a group's lottery assignment
class GroupSkipper
  include ActiveModel::Model
  include Callable

  validate :draw_past_lottery

  # Initialize a GroupLotteryNumberUpdater
  #
  # @param group [Group] The group
  def initialize(group:)
    @group = group
    @draw = group.draw
  end

  # Update the lottery number
  #
  # @return [Hash{Symbol=>Group,Hash,Nil}] the return hash
  def skip
    return error(self) unless valid?
    last_num = LastLotteryNumberQuery.call(draw: @draw)
    @group.lottery_assignment.update!(number: last_num + 1)
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :skip

  private

  def draw_past_lottery
    return if @draw.suite_selection?
    errors.add(:base, 'Draw must be in suite selection mode')
  end

  def success
    {
      redirect_object: nil,
      msg: { notice: "Group #{@group.name} skipped." }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      redirect_object: nil,
      msg: { error: "Group #{@group.name} could not be skipped: #{msg}" }
    }
  end
end
