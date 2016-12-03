# frozen_string_literal: true
#
# Service object to create tags.
class TagCreator < Creator
  # Initialize a TagCreator
  #
  # @param [ActionController::Parameters] params The params object from
  #   the TagsController.
  def initialize(params)
    super(klass: Tag, name_method: :name, params: params)
  end
end
