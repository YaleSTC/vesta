# frozen_string_literal: true
#
# Service object to create draws.
class DrawCreator < Creator
  # Initialize a DrawCreator
  #
  # @param [ActionController::Parameters] params The params object from
  #   the DrawsController.
  def initialize(params)
    super(klass: Draw, name_method: :name, params: params)
  end
end
