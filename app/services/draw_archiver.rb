# frozen_string_literal: true

# Service object to handle the archiving of a draw.
class DrawArchiver
  include ActiveModel::Model
  include Callable

  validates :draw, presence: true

  # Initialize a new DrawArchiver
  #
  # @param draw [Draw] the draw in question
  def initialize(draw:)
    @draw = draw
  end

  # Archive a Draw
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the created object.
  def archive
    return error(self) unless valid?
    # callbacks ensure that all draw_memberships associated with this draw
    #   will be marked inactive as well
    ActiveRecord::Base.transaction do
      draw.update!(active: false)
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :archive

  private

  attr_reader :draw

  def success
    { redirect_object: nil, msg: { success: 'Draw archived.' } }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: draw,
      msg: { error: "There was a problem archiving the draw:\n#{msg}" } }
  end
end
