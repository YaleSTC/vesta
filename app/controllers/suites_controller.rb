# frozen_string_literal: true
# Controller for Suites
class SuitesController < TaggableController
  before_action :set_suite, except: %i(new)

  def show
  end

  def new
    @suite = Suite.new
  end

  def create
    result = SuiteCreator.new(suite_params).create!
    @suite = result[:object] ? result[:object] : Suite.new
    handle_action(action: 'new', **result)
  end

  def edit
  end

  def update
    result = Updater.new(object: @suite, name_method: :number,
                         params: suite_params).update
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @suite, name_method: :number).destroy
    handle_action(**result)
  end

  def edit_tags
    @taggable = @suite
    @name = @suite.number
    super
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
    params.require(:suite).permit(:number, :building_id, :tag_ids)
  end

  def set_suite
    @suite = Suite.find(params[:id])
  end
end
