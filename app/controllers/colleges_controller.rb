# frozen_string_literal: true

#
# Controller for College resources
class CollegesController < ApplicationController
  prepend_before_action :set_current_college
  prepend_before_action :set_college, except: %i(show index new create archive)
  skip_before_action :set_current_college, only: %i(index)

  def show; end

  def index
    @colleges = College.all.order(name: :asc)
  end

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
    # normally this would redirect to 'show' but we want it to go to 'edit'
    handle_action(action: 'edit', **result.merge(redirect_object: nil))
  end

  def archive
    result = CollegeArchiver.archive
    handle_action(path: edit_college_path(College.current), **result)
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
    (action_name == 'index' && Apartment::Tenant.current == 'public')\
      || action_name == 'show'
  end

  def college_params
    params.require(:college).permit(:name, :admin_email, :dean, :floor_plan_url,
                                    :student_info_text, :subdomain,
                                    :restrict_clipping_group_size,
                                    :allow_clipping, :size_sort,
                                    :advantage_clips)
  end

  def set_college
    @college = College.find(params[:id])
  end
end
