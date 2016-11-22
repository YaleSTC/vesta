# frozen_string_literal: true
#
# Base class for updater service objects.
# Handles param conversion, perisistance, and provides default messages.
class Updater
  # Initialize a new Updater.
  #
  # @param [ApplicationRecord] object The object to be updated
  # @param [ActionController::Parameters] params The params object
  #   from the controller.
  # @param [Symbol] name_method The model method that gives an identifying
  #   name of the object (e.g. `#number` for Suite).
  def initialize(object:, params:, name_method:)
    @object = object
    @params = params.to_h.transform_keys(&:to_sym)
    @name_method = name_method
  end

  # Attempt to update an object.
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}]
  #   A results hash with a message to set in the flash and either `nil`
  #   or the updated object.
  def update
    if object.update_attributes(**params)
      success
    else
      error
    end
  end

  private

  attr_reader :object, :params, :name_method

  def success
    { object: object, msg: { notice: "#{object.send(name_method)} updated." } }
  end

  def error
    { object: nil, msg: { error: 'Please review the errors below.' } }
  end
end
