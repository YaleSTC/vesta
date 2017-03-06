# frozen_string_literal: true
#
# Service object to toggle whether or not a group size is locked for a given
# draw. Validates that the size is one for which there are currently available
# suites.
class DrawSizeLockToggler
  # permit calling :toggle on the base class
  def self.toggle(**params)
    new(**params).toggle
  end

  # Initialize a new DrawSizeLockToggler
  #
  # @param draw [Draw] the draw in question
  # @param size_str [String] the size param passed in the request
  def initialize(draw:, size:)
    @draw = draw
    @errors = []
    @size = parse_size(size)
  end

  def toggle
    return error(errors.join(', ')) unless valid?
    toggle_size_lock
    return success if draw.save
    error(draw.errors.full_messages.join(', '))
  end

  private

  attr_reader :draw, :size
  attr_accessor :errors

  def parse_size(size)
    errors << "Invalid size #{size}" unless integer_string?(size)
    size.to_i
  end

  def integer_string?(size)
    /^\d+$/.match(size)
  end

  def valid?
    errors.empty?
  end

  def toggle_size_lock
    if draw.size_locked?(size)
      draw.locked_sizes.delete_if { |s| s == size }
    else
      draw.locked_sizes << size
    end
  end

  def success
    { object: nil, msg: { success: success_msg } }
  end

  def error(errors)
    { object: nil, msg: { error: "Draw update failed: #{errors}" } }
  end

  def success_msg
    size_str = Suite.size_str(size).pluralize.capitalize
    if draw.reload.size_locked?(size)
      "#{size_str} locked"
    else
      "#{size_str} unlocked"
    end
  end
end
