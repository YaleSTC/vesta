# frozen_string_literal: true

# Controller for Suites
class SuitesController < ApplicationController
  prepend_before_action :set_suite, except: %i(new create index)
  prepend_before_action :set_building, only: %i(new create)

  def show
    @rooms = @suite.rooms.order(:number)
    @draws = @suite.draws
    @building = @suite.building
    @group = @suite.group
    @merger_form = SuiteMergerForm.new(suite: @suite)
  end

  def new
    @suite = Suite.new
  end

  def create
    result = Creator.create!(klass: Suite, params: suite_params,
                             name_method: :number)
    @suite = result[:record]
    handle_action(action: 'new', **result)
  end

  def edit; end

  def update
    result = Updater.update(object: @suite, params: suite_params,
                            name_method: :number)
    @suite = result[:record]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @suite, name_method: :number).destroy
    handle_action(path: building_path(@suite.building), **result)
  end

  def merge
    @merger_form = SuiteMergerForm.new(suite: @suite,
                                       params: suite_merger_params)
    unless @merger_form.valid?
      flash[:error] = 'Invalid suite number'
      redirect_to(suite_path(@suite)) && return
    end
    @other_suite = @merger_form.other_suite
    @all_rooms = @suite.rooms + @merger_form.other_suite.rooms
  end

  def perform_merge
    result = SuiteMergerForm.submit(suite: @suite, params: suite_merger_params)
    @merger_form = result[:form_object] if result[:form_object]
    @all_rooms = find_merger_rooms if @merger_form
    handle_action(action: 'merge', **result)
  end

  def split
    @split_form = SuiteSplitForm.new(suite: @suite)
  end

  def perform_split
    result = SuiteSplitForm.submit(suite: @suite, params: suite_split_params)
    @split_form = result[:form_object] if result[:form_object]
    handle_action(path: building_path(@suite.building), **result)
  end

  def unmerge
    result = SuiteUnmerger.unmerge(suite: @suite)
    handle_action(**result)
  end

  private

  def authorize!
    if @suite
      authorize @suite
    else
      authorize Suite
    end
  end

  def suite_params
    params.require(:suite).permit(:number, :building_id, :medical)
  end

  def suite_merger_params
    params.require(:suite_merger_form).permit(:number, :other_suite_number)
  end

  def suite_split_params
    valid_params = @suite.rooms.map { |r| "room_#{r.id}_suite".to_sym }
    params.require(:suite_split_form).permit(*valid_params)
  end

  def set_suite
    @suite = Suite.includes(:rooms).find(params[:id])
  end

  def set_building
    @building = Building.find(params[:building_id])
  end

  def find_merger_rooms
    id_array = [@suite.id, @merger_form.other_suite.id]
    Room.includes(:suite).where(suites: { id: id_array })
  end
end
