# frozen_string_literal: true

# Service object to handle the archiving of all drawless groups.
class DrawlessGroupArchiver
  include ActiveModel::Model
  include Callable

  # Archive all active DrawlessGroups
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and either `nil` or the created object.
  def archive
    drawless_draw_memberships = DrawMembership.where(draw: nil, active: true)
    return success unless drawless_draw_memberships.present?
    ActiveRecord::Base.transaction do
      drawless_draw_memberships.map { |dm| dm.update!(active: false) }
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :archive

  private

  attr_reader :drawless_draw_memberships

  def success
    {
      redirect_object: nil, msg:
      {
        success: 'All active special groups archived.'
      }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    { redirect_object: nil,
      msg: { error: "There was a problem archiving the groups:\n#{msg}" } }
  end
end
