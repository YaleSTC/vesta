# frozen_string_literal: true

#
# Service object to handle accepting the terms of service for Vesta
class TermsOfServiceAccepter
  include ActiveModel::Model
  include Callable

  validates :user, presence: true

  # Initialize a new Updater.
  #
  # @param user [User] the user to be updated
  def initialize(user:)
    @user = user
  end

  # Attempt to accept the terms of service.
  #
  # @return [Hash{Symbol=>User,Hash}]
  #   A results hash with a message to set in the flash and either `nil`
  #   or the path to redirect to.
  def accept
    return error(self) unless valid?
    user.update!(tos_accepted: Time.current)
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :accept

  private

  attr_reader :user

  # The handle_action helper defaults to redirecting to root_path
  # if no actions, paths, or redirect_objects are given.
  def success
    {
      redirect_object: nil, msg: { success: 'Welcome to Vesta!' }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      action: 'show', redirect_object: nil,
      msg: { error: "Oops, something went wrong. Please try again.\n#{msg}" }
    }
  end
end
