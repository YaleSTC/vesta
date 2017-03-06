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

  def diff_class(diff)
    raise ArgumentError unless diff.is_a? Integer
    return 'positive' if diff.positive?
    return 'negative' if diff.negative?
    'zero'
  end

  # Return the link to lock or unlock a specific group size for a draw
  def toggle_size_lock_btn(draw:, size:, path:)
    return lock_size_btn(draw, size, path) unless draw.size_locked?(size)
    unlock_size_btn(draw, size, path)
  end

  # Return the link/button to proceed from the pre-lottery phase. Takes draw
  # oversubscription status into account and modifies text and class as
  # necessary.
  #
  # @param draw [Draw] the draw
  # @return [String] the link
  def proceed_from_pre_lottery_btn(draw)
    options = if draw.oversubscribed?
                { class: 'button alert', method: :patch }
              else
                { class: 'button', method: :patch }
              end
    link_to 'Proceed to lottery', start_lottery_draw_path(draw), **options
  end

  private

  def day_str(n)
    "#{n} #{'day'.pluralize(n)}"
  end

  def lock_size_btn(draw, size, path)
    link_to "Lock #{headerize_size(size)}",
            toggle_size_lock_draw_path(draw, size, redirect_path: path),
            method: :patch, **with_tooltip(
              text: "Prevent students from forming more groups of size #{size}",
              class_override: 'button', id: "lock-size-#{size}"
            )
  end

  def unlock_size_btn(draw, size, path)
    link_to "Unlock #{headerize_size(size)}",
            toggle_size_lock_draw_path(draw, size, redirect_path: path),
            method: :patch, **with_tooltip(
              text: "Allow studenst to form groups of size #{size}",
              class_overrides: 'button', id: "unlock-size-#{size}"
            )
  end
end
