# frozen_string_literal: true

# Formats errors in service objects
class ErrorHandler
  # Converts ActiveModel error messages into a string, joined by commas
  #
  # @param error_object [#record, #errors] The object with validation errors
  #
  # @return [String] A comma-joined list of all validation error messages
  def self.format(error_object:)
    error_object = error_object.record if error_object.respond_to? :record
    error_object.errors.full_messages.join(', ')
  end
end
