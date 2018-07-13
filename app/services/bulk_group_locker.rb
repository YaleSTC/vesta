# frozen_string_literal: true

# Service object to set all undeclared students in a draw to on_campus intent
class BulkGroupLocker
  include Callable
  include ActiveModel::Model

  validate :draw_is_not_oversubscribed

  # @param draw [Draw] the draw in question
  def initialize(draw:)
    @draw = draw
  end

  # Perform the bulk intent update
  #
  # @return [Hash{Symbol=>Draw,Hash}] a results hash with the draw assigned to
  #   :redirect_object and a success flash message
  def update
    return error(self) unless valid?
    lock_all_groups
    success
  end

  make_callable :update

  private

  attr_reader :draw

  def lock_all_groups
    draw.groups.where(status: %w(closed finalizing))
        .map { |g| GroupLocker.lock(group: g) }
  end

  def draw_is_not_oversubscribed
    return unless draw.oversubscribed?
    error_message = 'You must handle oversubscription before locking groups'
    errors.add(:base, error_message)
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      redirect_object: draw, msg: { error: msg }
    }
  end

  def success
    { redirect_object: draw,
      msg: { success: 'All groups have been locked' } }
  end
end
