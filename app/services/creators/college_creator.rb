# frozen_string_literal: true

# Service object to create colleges.
class CollegeCreator
  include ActiveModel::Model
  include Callable
  include Rails.application.routes.url_helpers

  validate :superuser_is_granted_access

  # Initialize a CollegeCreator
  #
  # @param [ActionController::Parameters] params The params object from
  #   the CollegesController.
  # @param user_for_access [User] the user to be granted access to the new
  #   college
  def initialize(params:, user_for_access:)
    @params = params.to_h.transform_keys(&:to_sym)
    @user_for_access = user_for_access
    @college = College.new(@params)
  end

  # Attempt to create a new college. If the creation is successful, switch to
  # the new tenant and save the user_for_access record in the new schema.
  #
  # @return [Hash{Symbol=>College,Hash,nil,String}] a results hash with a
  #   message to set in the flash, the college record (persisted or not), nil as
  #   the :redirect_object value, and either nil or the new college home URL as
  #   the :path
  def create!
    return error(self) unless valid?
    ActiveRecord::Base.transaction do
      college.save!
      clone_user_for_access
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :create!

  private

  attr_accessor :user_for_access, :college

  def superuser_is_granted_access
    return if user_for_access.superuser?
    errors.add(:base, 'You must grant access the new college to a superuser')
  end

  def clone_user_for_access
    # Note that this runs in a transaction
    current_college = College.current
    UserCloner.clone(username: user_for_access.login_attr,
                     from: current_college, to: college, io: StringIO.new)
    current_college.activate!
  end

  def success
    redirect_path = root_url(host: college.host)
    {
      redirect_object: nil, college: college, path: redirect_path,
      msg: { success: "#{college.name} college created." }
    }
  end

  def error(error_obj)
    msg = ErrorHandler.format(error_object: error_obj)
    {
      redirect_object: nil, college: college,
      msg: { error: "Please review the errors below:\n#{msg}" }
    }
  end
end
