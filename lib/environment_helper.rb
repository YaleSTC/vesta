# frozen_string_literal: true

# Helper methods for dealing with environment variables.
module EnvironmentHelper
  FALSE = [0, '0', false, 'false', nil, ''].freeze

  # Check an environment variable for a 'falsey' value, as defined by the
  # constant FALSE above.
  #
  # @return [Boolean] false if the environment variable constains a falsey
  #   true otherwise
  def env?(var)
    !FALSE.include? ENV[var]
  end

  # Returns the value of an environment value, assuming it does not contain a
  # falsey value as defined by constant FALSE above.
  #
  # @return [String, nil] the content of the environment variable if it does not
  #   contain a falsey value, nil otherwise
  def env(var)
    return nil unless env?(var)
    ENV[var]
  end
end
