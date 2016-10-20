# frozen_string_literal: true
# Controller for Buildings
class BuildingsController < ApplicationController
  before_action :set_building, only: :show

  def show
  end

  def new
    @building = Building.new
  end

  def create
    result = BuildingCreator.new(building_params).create!
    @building = result[:object] ? result[:object] : Building.new
    handle_create(**result)
  end

  private

  def building_params
    params.require(:building).permit(:name)
  end

  def set_building
    @building = Building.find(params[:id])
  end
end
