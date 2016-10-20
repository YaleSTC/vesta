# frozen_string_literal: true
# Base controller class.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, only: :index

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
end
