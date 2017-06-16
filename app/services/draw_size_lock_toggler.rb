# frozen_string_literal: true

#
# Service object to toggle whether or not a group size is locked for a given
# draw. Validates that the size is one for which there are currently available
# suites.
class DrawSizeLockToggler
  include ActiveModel::Model
  include Callable

  validate :size_is_an_integer_string

  # Initialize a new DrawSizeLockToggler
  #
  # @param draw [Draw] the draw in question
  # @param size [String] the size param passed in the request
  def initialize(draw:, size:)
    @draw = draw
    @size = size
  end

  def toggle
    return error(self) unless valid?
    toggle_size_lock
    draw.save!
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :toggle

  private

  attr_reader :draw, :size

  def size_is_an_integer_string
    if @size =~ /^\d+$/
      @size = @size.to_i
    else
      errors.add(:size, "#{size} is invalid.")
    end
  end

  def toggle_size_lock
    if draw.size_locked?(size)
      draw.locked_sizes.delete_if { |s| s == size }
    else
      draw.locked_sizes << size
    end
  end

  def success
    { redirect_object: nil, msg: { success: success_msg } }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: nil, msg: { error: "Draw update failed: #{msg}" } }
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
