# frozen_string_literal: true
#
# Controller for College resources
class CollegesController < ApplicationController
  prepend_before_action :set_college, except: %i(new create)

  def show; end

  def new
    @college = College.new
  end

  def create
    result = Creator.new(klass: College, params: college_params,
                         name_method: :name).create!
    @college = result[:record]
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = Updater.new(object: @college, name_method: :name,
                         params: college_params).update
    @college = result[:record]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @college, name_method: :name).destroy
    handle_action(**result)
  end

  private

  def authorize!
    if @college
      authorize @college
    else
      authorize College
    end
  end

  def college_params
    params.require(:college).permit(:name, :admin_email, :dean, :site_url)
  end

  def set_college
    @college = current_college
  end
end
