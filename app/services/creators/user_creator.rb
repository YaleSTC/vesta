# frozen_string_literal: true
#
# Service object to create users.
class UserCreator
  # Allow for the calling of :create! on the parent class
  def self.create!(params)
    new(params).create!
  end

  # Initialize a UserCreator
  #
  # @param [ActionController::Parameters] params The params object from
  #   the UsersController.
  def initialize(params, mailer = UserMailer)
    @params = params.to_h.transform_keys(&:to_sym)
    @mailer = mailer
    @user = User.new(@params)
    set_password unless cas_auth?
  end

  # Attempt to create a new user. If CAS auth is NOT enabled, autogenerates a
  # password and sends it in the confirmation e-mail.
  #
  # @return [Hash{Symbol=>User,Hash}] a results hash with a message to set in
  #   the flash, the user record (persisted or not), and either nil or the
  #   record as the :object value
  def create!
    return error unless user.save
    mailer.new_user_confirmation(user: user, password: password).deliver_later
    success
  end

  private

  attr_accessor :password, :user
  attr_reader :mailer

  def set_password
    @password ||= Devise.friendly_token(12)
    user.password = @password
    user.password_confirmation = @password
  end

  def cas_auth?
    User.cas_auth?
  end

  def success
    {
      object: user, user: user,
      msg: { success: "User #{user.full_name} created." }
    }
  end

  def error
    errors = user.errors.full_messages
    {
      object: nil, user: user,
      msg: { error: "Please review the errors below:\n#{errors.join("\n")}" }
    }
  end
end
