# frozen_string_literal: true
# Controller for Suites
class SuitesController < ApplicationController
  prepend_before_action :set_suite, only: %i(show edit update destroy activate
                                             deactivate)

  def show
    @rooms = @suite.rooms
  end

  def new
    @suite = Suite.new
  end

  def create
    result = SuiteCreator.new(suite_params).create!
    @suite = result[:record]
    handle_action(action: 'new', **result)
  end

  def edit
  end

  def update
    result = Updater.new(object: @suite, name_method: :number,
                         params: suite_params).update
    @suite = result[:record]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @suite, name_method: :number).destroy
    handle_action(**result)
  end

  def deactivate
    if @suite.deactivate.save
      flash[:success] = 'Suite successfully deactivated'
      redirect_to(@suite)
    else
      errors = @suite.errors.full_messages.join(', ')
      flash[:error] = "Suite could not be deactivated: #{errors}"
      render 'show'
    end
  end

  def activate
    if @suite.activate.save
      flash[:success] = 'Suite successfully activated'
      redirect_to(@suite)
    else
      errors = @suite.errors.full_messages.join(', ')
      flash[:error] = "Suite could not be activated: #{errors}"
      render 'show'
    end
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
    params.require(:suite).permit(:number, :building_id)
  end

  def set_suite
    @suite = Suite.find(params[:id])
  end
end
