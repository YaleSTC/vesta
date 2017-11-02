# frozen_string_literal: true

# Helper for lottery assignments
module LotteryAssignmentsHelper
  # Return a CSS selector for the lottery assignment form wrapper
  #
  # @param lottery [LotteryAssignment] the lottery assignment in question
  # @return [String] a CSS selector
  def lottery_form_id(lottery)
    base = 'lottery-form'
    return "#{base}-clip-#{lottery.clip_id}" if lottery.clip_id.present?
    return "#{base}-group-#{lottery.group.id}" if lottery.group.present?
    raise ArgumentError
  end

  # Return a link to the clip or group that "owns" the lottery assignment
  #
  # @param lottery [LotteryAssignment] the lottery assignment in question
  # @return [String] a link to the clip or group
  def lottery_owner_url(lottery)
    return clip_path(lottery.clip_id) if lottery.clip_id.present?
    raise ArgumentError unless lottery.group.present?
    draw_group_path(lottery.draw, lottery.group)
  end
end
