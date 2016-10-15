# frozen_string_literal: true
# Base controller class.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  def index
  end
end
