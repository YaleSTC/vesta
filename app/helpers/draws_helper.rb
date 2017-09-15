# frozen_string_literal: true

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
    return '' unless diff.is_a? Integer
    return 'positive' if diff.positive?
    return 'negative' if diff.negative?
    'zero'
  end

  # Return a string describing the subscription status of a group size in words
  def oversub_str(diff)
    return ' (oversubscribed)' if diff.negative?
    return ' (fully subscribed)' if diff.zero?
    ''
  end

  # Return the link to lock or unlock a specific group size for a draw
  def toggle_size_lock_btn(draw:, size:, path:)
    return lock_size_btn(draw, size, path) unless draw.size_locked?(size)
    unlock_size_btn(draw, size, path)
  end

  # Return the appropriate class for starting a lottery based on the draw's
  # oversubscription status
  #
  # @return [String] the class
  def start_lottery_btn_class(draw)
    draw.oversubscribed? ? 'button alert' : 'button'
  end

  # Determines the label for the intent lock toggle button
  #
  # @return [String] The button label
  def lock_intent_btn_label(draw)
    draw.intent_locked ? 'Unlock Intents' : 'Lock Intents'
  end

  # Determines the tooltip for the intent lock toggle button
  #
  # @return [String] The button tooltip
  def lock_intent_btn_tooltip(draw)
    if draw.intent_locked
      'Allow students to update their housing intent'
    else
      'Prevent students from changing their housing intent'
    end
  end

  # Formats the last email sent datetime
  #
  # @return [String] in format "March 21, 2:00 pm"
  def format_email_date(date)
    date.strftime('%B %e, %l:%M %P')
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
              class_override: 'button expanded', id: "lock-size-#{size}"
            )
  end

  def unlock_size_btn(draw, size, path)
    link_to "Unlock #{headerize_size(size)}",
            toggle_size_lock_draw_path(draw, size, redirect_path: path),
            method: :patch, **with_tooltip(
              text: "Allow students to form groups of size #{size}",
              class_override: 'button expanded', id: "unlock-size-#{size}"
            )
  end
end
