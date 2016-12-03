class TaggableController < ApplicationController
  before_action :set_tag, only: %i(add_tag remove_tag)

  def edit_tags
    @tags = Tag.all
  end

  def add_tag
  end

  def remove_tag
  end

  private

  def taggable_params
    params.permit(:tag_id)
  end

  def set_tag
    @tag = Tag.find(params[:tag_id])
  end
end
