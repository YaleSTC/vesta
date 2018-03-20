# frozen_string_literal: true

#
# Controller for College resources
class CollegesController < ApplicationController
  prepend_before_action :set_college, except: %i(index new create)
  skip_before_action :set_current_college, only: %i(index)

  def index
    @colleges = College.all.order(name: :asc)
  end

  def show; end

  def new
    @college = College.new
  end

  def create
    result = CollegeCreator.create!(params: college_params,
                                    user_for_access: current_user)
    @college = result[:college]
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = Updater.new(object: @college, name_method: :name,
                         params: college_params).update
    @college = result[:record]
    handle_action(action: 'edit', **result)
  end

  private

  def authorize!
    if @college
      authorize @college
    else
      authorize College
    end
  end

  def unauthenticated?
    action_name == 'index' && Apartment::Tenant.current == 'public'
  end

  def college_params
    params.require(:college).permit(:name, :admin_email, :dean, :floor_plan_url,
                                    :student_info_text, :subdomain)
  end

  def set_college
    @college = College.find(params[:id])
  end
end
