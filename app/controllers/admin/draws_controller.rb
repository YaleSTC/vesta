# frozen_string_literal: true

module Admin
  # Controller for Administrate draw dashboards
  class DrawsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Draw.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Draw.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    private

    def resource_params
      params.require(resource_name)
            .permit(*dashboard.permitted_attributes, locked_sizes: [])
    end
  end
end
