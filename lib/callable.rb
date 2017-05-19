# frozen_string_literal: true

# Module to make it easy to implement methods like the following:
#   def self.foo(**params)
#     new(**params).foo
#   end
#
# To use:
# class Bar
#   include Callable
#
#   def foo; end
#
#   make_callable :foo
# end
module Callable
  # In order to define class methods through a module, the methods
  # are defined in a submodule
  module ClassMethods
    ERR_STRING = 'Method not defined on class. Are you sure that '\
      'make_callable is being called after you define the instance method?'

    # Defines the following class method:
    #   def self.method_name(**params)
    #     new(**params).method_name
    #   end
    #
    # Raises an ArgumentError if the instance method is not defined
    #
    # @param method_name [Symbol] The name of the class method to be defined
    def make_callable(method_name)
      raise ArgumentError, ERR_STRING unless method_defined? method_name
      define_singleton_method(method_name) do |**params|
        new(**params).send(method_name)
      end
    end
  end

  # Callback that adds all of the methods in ClassMethods to the class
  #
  # @param receiver [Class] The class that will have methods added to it
  def self.included(receiver)
    receiver.extend(ClassMethods)
  end
end
