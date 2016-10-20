# frozen_string_literal: true
#
# Service object to create buildings.
class BuildingCreator < Creator
  # Initialize a BuildingCreator
  #
  # @param [ActionController::Parameters] params The params object from
  #   the BuildingsController.
  def initialize(params)
    super(klass: Building, name_method: :name, params: params)
  end
end
