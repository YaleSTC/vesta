# frozen_string_literal: true

#
# Base class for destroyer service objects. Provides default messages.
class Destroyer
  include Callable

  # Initialize a new Destroyer.
  #
  # @param [ApplicationRecord] object The model object to be destroyed
  # @param [Symbol] name_method The model method that gives an identifying
  #   name of the object (e.g. `#number` for Suite).
  def initialize(object:, name_method:)
    @object = object
    @name = object.send(name_method)
    @klass = object.class
  end

  # Attempt to destroy an object.
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}]
  #   A results hash with a message to set in the flash and either `nil`
  #   or the object that was not destroyed
  def destroy
    if object.destroy
      success
    else
      error
    end
  end

  make_callable :destroy

  private

  attr_reader :object, :name, :klass

  def success
    { redirect_object: nil, msg: { notice: "#{klass} #{name} deleted." } }
  end

  def error
    { redirect_object: object,
      msg: { error: "#{klass} #{name} couldn't be deleted." } }
  end
end
