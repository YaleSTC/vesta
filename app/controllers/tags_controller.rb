# frozen_string_literal: true
# Controller for Tags
class TagsController < ApplicationController
  before_action :set_tag, only: %i(show edit update destroy)

  def show
  end

  def new
    @tag = Tag.new
  end

  def create
    result = TagCreator.new(tag_params).create!
    @tag = result[:object] ? result[:object] : Tag.new
    handle_action(action: 'new', **result)
  end

  def edit
  end

  def update
    result = Updater.new(object: @tag, name_method: :name,
                         params: tag_params).update
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.new(object: @tag, name_method: :name).destroy
    handle_action(**result)
  end

  private

  def authorize!
    if @tag
      authorize @tag
    else
      authorize Tag
    end
  end

  def tag_params
    params.require(:tag).permit(:name)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end
end
