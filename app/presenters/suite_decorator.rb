# frozen_string_literal: true

# Presenter object for suites
# Delegates to suite model
class SuiteDecorator < SimpleDelegator
  # Initialize a new SuiteDecorator
  #
  # @param [Suite] suite The suite object to decorate
  def initialize(suite)
    @suite = suite
    super(suite)
  end

  # Return the building name with the suite number
  #
  # @return [String] the building name with the suite number
  def name
    "#{building.name} #{number}"
  end

  # Return the building name with the suite number and the medical status
  #
  # @return [String] the building name with the suite number and medical status
  def name_with_medical
    return name unless medical
    "#{name} (medical)"
  end

  # Return the name of the suite with the names of any draws it belongs to.
  # Optionally excludes a single draw passed in.
  #
  # @param [Draw] the draw to exclude
  # @return [String] the suite name with draw names
  def name_with_draws(draw = nil)
    return name if draws.empty?
    draws_to_display = draws.where.not(id: draw&.id, active: false)
    return name if draws_to_display.empty?
    draws_str = draws_to_display.map(&:name).join(', ')
    "#{name} (#{draws_str})"
  end

  # Return the suite number, indicating if the suite is a medical suite or not
  #
  # @return [String] the number with medical status indicated
  def number_with_medical
    return number unless medical
    "#{number} (medical)"
  end
end
