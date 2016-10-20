# frozen_string_literal: true
# Controller for Suites
class SuitesController < ApplicationController
  before_action :set_suite, only: :show

  def show
  end

  def new
    @suite = Suite.new
  end

  def create
    result = SuiteCreator.new(suite_params).create!
    @suite = result[:object] ? result[:object] : Suite.new
    handle_create(**result)
  end

  private

  def set_suite
    @suite = Suite.find(params[:id])
  end

  def suite_params
    params.require(:suite).permit(:number, :building_id)
  end
end
