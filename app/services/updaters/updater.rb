# frozen_string_literal: true

#
# Base class for updater service objects.
# Handles param conversion, perisistance, and provides default messages.
class Updater
  include Callable

  # Initialize a new Updater.
  #
  # @param object [ApplicationRecord] The object to be updated
  # @param params [#to_h] The params with the new attributes
  # @param name_method [Symbol] The model method that gives an identifying
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
    if object.update(**params)
      success
    else
      error
    end
  end

  make_callable :update

  private

  attr_reader :object, :params, :name_method

  def success
    {
      redirect_object: object, record: object,
      msg: { notice: "#{object.send(name_method)} updated." }
    }
  end

  def error
    msg = ErrorHandler.format(error_object: object)
    {
      redirect_object: nil, record: object,
      msg: { error: "Please review the errors below:\n#{msg}" }
    }
  end
end
