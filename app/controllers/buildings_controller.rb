# frozen_string_literal: true

# Controller for Buildings
class BuildingsController < ApplicationController
  prepend_before_action :set_building, except: %i(new create index)

  def show
    @suite_importer = SuiteImportForm.new(building: @building)
    @suites = SuitesBySizeQuery.new(@building.suites.includes(:rooms)).call
  end

  def new
    @building = Building.new
  end

  def index
    @buildings = Building.all
    @suites_by_size = @buildings.map { |b| [b.id, b.suites_by_size] }.to_h
  end

  def create
    result = Creator.create!(params: building_params, klass: Building,
                             name_method: :name)
    @building = result[:record]
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = Updater.new(object: @building, name_method: :name,
                         params: building_params).update
    @building = result[:record]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @building, name_method: :name).destroy
    handle_action(path: buildings_path, **result)
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
