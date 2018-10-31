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

  # Return the link to restrict or permit a specific group size for a draw
  def toggle_size_restricted_btn(draw:, size:, path:)
    return restrict_size_btn(draw, size, path) \
      unless draw.size_restricted?(size)
    permit_size_btn(draw, size, path)
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

  # Return the button string for draw activation, indicates intent selection if
  # intent is unlocked and group formaton otherwise
  #
  # @param draw [Draw] the draw in question
  # @return [String] the appropriate button string
  def draw_activation_btn_str(draw)
    return 'Begin group formation phase' if draw.intent_locked
    'Begin intent selection phase'
  end

  # Return the confirmation string text for draw activation, indicates intent
  # selection if intent is unlocked and group formaton otherwise
  #
  # @param draw [Draw] the draw in question
  # @return [String] the appropriate confirmation string
  def draw_activation_confirm_action(draw)
    return 'forming groups' if draw.intent_locked
    'declaring intent'
  end

  private

  def day_str(n)
    "#{n} #{'day'.pluralize(n)}"
  end

  def restrict_size_btn(draw, size, path)
    link_to "Restrict #{headerize_size(size)}",
            toggle_size_restrict_draw_path(draw, size, redirect_path: path),
            method: :patch, **with_tooltip(
              text: "Prevent students from forming more groups of size #{size}",
              class_override: 'button expanded', id: "restrict-size-#{size}"
            )
  end

  def permit_size_btn(draw, size, path)
    link_to "Permit #{headerize_size(size)}",
            toggle_size_restrict_draw_path(draw, size, redirect_path: path),
            method: :patch, **with_tooltip(
              text: "Allow students to form groups of size #{size}",
              class_override: 'button expanded', id: "permit-size-#{size}"
            )
  end
end
