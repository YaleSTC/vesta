# frozen_string_literal: true

# Base controller class.
class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :authenticate_user!, unless: :unauthenticated?
  before_action :authorize!, unless: :unauthenticated?
  before_action :set_current_college
  before_action :verify_tos_accepted, unless: :unauthenticated?
  after_action :verify_authorized, unless: :unauthenticated?

  rescue_from Pundit::NotAuthorizedError do |exception|
    Honeybadger.notify(exception)
    flash[:error] = "Sorry, you don't have permission to do that."
    redirect_to request.referer.present? ? request.referer : root_path
  end

  private

  def unauthenticated?
    devise_controller? || self.class == HighVoltage::PagesController
  end

  # Abstract method to handle object CRUD. Handles success, failure,
  # and setting the flash appropriately.
  #
  # @abstract
  # @param [ApplicationRecord] object The object key from the service object
  #   results
  # @param [Hash{Symbol=>String}] msg The msg key from the service object
  #   results
  # @param [String] action The action to render when no object passed.
  #   (Creation / update failure, destruction success)
  # @param [String] path The path to redirect to when no object passed.
  def handle_action(redirect_object:, msg:, action: nil, path: nil, **_)
    msg.each { |flash_type, msg_str| flash[flash_type] = msg_str }
    redirect_to(redirect_object) && return if redirect_object
    complete_request(action: action, path: path)
  end

  def complete_request(action: nil, path: nil)
    if path
      redirect_to path
    elsif action
      render action: action
    else
      redirect_to root_path
    end
  end

  # Abstract method to handle file export actions. Handles success, failure,
  # and setting the flash appropriately.
  #
  # @abstract
  # @param file [Object] the file to be exported.
  # @param filename [String] the file name.
  # @param type [String] the type of the file (ex: 'text/csv').
  # @param errors [String] the errors incurred during file creation, if any.
  def handle_file_action(file:, filename:, type:, errors: nil)
    if errors
      flash[:error] = errors
      redirect_to request.referer
    else
      send_data(file, filename: filename, type: type)
    end
  end

  # Abstract method to enforce permissions authorization in all controllers.
  # Must be overridden in all controllers.
  #
  # @abstract
  def authorize!
    raise NoMethodError
  end

  def set_current_college
    @current_college ||= College.current
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Please select a valid college to proceed.'
    redirect_to colleges_path
  end

  def verify_tos_accepted
    return if current_user.admin? || current_user.tos_accepted
    flash[:error] = 'You must accept the Terms of Service to proceed.'
    redirect_to terms_of_service_path
  end
end
