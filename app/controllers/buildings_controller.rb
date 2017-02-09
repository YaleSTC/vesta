# frozen_string_literal: true
# Controller for Buildings
class BuildingsController < ApplicationController
  prepend_before_action :set_building, only: %i(show edit update destroy)

  def show
  end

  def new
    @building = Building.new
  end

  def create
    result = BuildingCreator.new(building_params).create!
    @building = result[:record]
    handle_action(action: 'new', **result)
  end

  def edit
  end

  def update
    result = Updater.new(object: @building, name_method: :name,
                         params: building_params).update
    @building = result[:record]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @building, name_method: :name).destroy
    handle_action(**result)
  end

  private

  def authorize!
    if @building
      authorize @building
    else
      authorize Building
    end
  end

  def building_params
    params.require(:building).permit(:name)
  end

  def set_building
    @building = Building.find(params[:id])
  end
end
