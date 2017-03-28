# frozen_string_literal: true
#
# Abstract base class for creator service objects.
# Handles param conversion, perisistance, and provides default messages.
#
# @abstract
class Creator
  # Initialize a new Creator.
  #
  # @param klass [Class] The model class to be created.
  # @param params [#to_h] The params for object.
  # @param name_method [Symbol] The model method that gives an identifying
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
    @obj = klass.send(:new, **params)
    if obj.save
      success
    else
      error
    end
  rescue ActiveRecord::RecordInvalid => e
    error(e.record)
  end

  private

  attr_reader :klass, :params, :name_method, :obj

  def success
    {
      object: obj, record: obj,
      msg: { success: "#{obj.send(name_method)} created." }
    }
  end

  def error(object = obj)
    errors = object.errors.full_messages
    {
      object: nil, record: obj,
      msg: { error: "Please review the errors below:\n#{errors.join("\n")}" }
    }
  end
end
