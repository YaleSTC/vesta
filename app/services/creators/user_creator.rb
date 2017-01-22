# frozen_string_literal: true
#
# Service object to create Users.
class UserCreator < Creator
  # Initialize a new UserCreator
  #
  # @param [ActionController::Parameters] params The params object from
  #   the UserController.
  def initialize(params)
    super(klass: User, name_method: :name, params: params)
  end
end
