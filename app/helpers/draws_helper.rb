# frozen_string_literal: true
#
# Helper module for Draws
module DrawsHelper
  def intent_deadline_str(draw)
    diff = (draw.intent_deadline - Time.zone.today).to_i
    if diff.positive?
      "The intent deadline is in #{day_str(diff)}."
    elsif diff.negative?
      "The intent deadline was #{day_str(diff.abs)} ago."
    else
      'The intent deadline is today.'
    end
  end

  private

  def day_str(n)
    "#{n} #{'day'.pluralize(n)}"
  end
end