# frozen_string_literal: true
#
# Abstract base class for creator service objects.
# Handles param conversion, perisistance, and provides default messages.
#
# @abstract
class Creator
  # Initialize a new Creator.
  #
  # @param [Class] klass The model class to be created
  # @param [ActionController::Parameters] params The params object
  #   from the controller.
  # @param [Symbol] name_method The model method that gives an identifying
  #   name of the object (e.g. `#number` for Suite).
  def initialize(klass:, params:, name_method:)
    @klass = klass
    @params = params.to_h.transform_keys(&:to_sym)
    @name_method = name_method
  end

  # Attempt to create a new object of type klass.
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}]
  #   A results hash with a message to set in the flash and either `nil`
  #   or the created object.
  def create!
    obj = klass.send(:new, **params)
    if obj.save
      success(obj)
    else
      error
    end
  end

  private

  attr_reader :klass, :params, :name_method

  def success(obj)
    { object: obj, msg: { notice: "#{obj.send(name_method)} created." } }
  end

  def error
    { object: nil, msg: { error: 'Please review the errors below.' } }
  end
end
