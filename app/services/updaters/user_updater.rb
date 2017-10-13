# frozen_string_literal: true

# Service object to update Users
class UserUpdater < Updater
  validate :admin_demote_self

  # Initialize a UserUpdater
  #
  # @param user [User] The user to be updated
  # @param params [#to_h] The new attributes
  # @param editing_self [Boolean] True if the user is editing themselves,
  #   false otherwise
  def initialize(user:, params:, editing_self:)
    super(object: user, params: params, name_method: :name)
    @editing_self = editing_self
  end

  private

  # Checks to see if the user is an admin and trying to change their role
  def admin_demote_self
    return unless @editing_self && @object.admin? && params[:role] != 'admin'
    errors.add(:base, 'You cannot demote yourself.')
  end
end
