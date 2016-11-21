# frozen_string_literal: true
# Base controller class.
class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :authorize!, except: :index, unless: :devise_controller?
  after_action :verify_authorized, except: :index, unless: :devise_controller?

  def index
  end

  private

  # Abstract method to handle object creation. Handles creation
  # success, failure, and setting the flash appropriately.
  #
  # @abstract
  # @param [ApplicationRecord] object The object key from the Creator results
  # @param [Hash{Symbol=>String}] msg The msg key from the Creator results
  def handle_create(object:, msg:)
    flash_type = msg.keys.first
    flash[flash_type] = msg[flash_type]
    if object
      redirect_to object
    else
      render action: 'new'
    end
  end

  # Abstract method to enforce permissions authorization in all controllers.
  # Must be overridden in all controllers.
  #
  # @abstract
  def authorize!
    raise NoMethodError
  end
end
