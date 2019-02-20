# frozen_string_literal: true

# Service object that resets TOS acceptance for all non-admins
#   across all colleges.
class BulkTosResetter
  include ActiveModel::Model
  include Callable

  # Reset all non-admin TOS acceptances
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}] A results hash with the
  #   message to set in the flash and 'nil' set as the redirect object.
  def reset
    ActiveRecord::Base.transaction do
      users = User.where(role: %w(student rep graduated))
      users.map { |u| u.update!(tos_accepted: nil) }
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :reset

  private

  def success
    {
      redirect_object: nil,
      msg: { success: 'Terms of service for all users has been reset.' }
    }
  end

  # We will be redirecting to the college#edit path for both success and error
  def error(e)
    msg = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil,
      msg:
      {
        error: "There was a problem resetting the terms of services:\n#{msg}"
      }
    }
  end
end
