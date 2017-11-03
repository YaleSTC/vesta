# frozen_string_literal: true

# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  # Base Controller for adminsistrate dashboards
  class ApplicationController < Administrate::ApplicationController
    include Pundit
    before_action :authenticate_user!
    before_action :authorize!

    rescue_from Pundit::NotAuthorizedError do |exception|
      Honeybadger.notify(exception)
      flash[:error] = "Sorry, you don't have permission to do that."
      redirect_to request.referer.present? ? request.referer : root_path
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    private

    def authorize!
      authorize :application, :superuser_dash?
    end
  end
end
