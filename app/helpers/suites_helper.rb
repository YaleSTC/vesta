# frozen_string_literal: true

# Helper module for Suites
module SuitesHelper
  # Returns the button string for the medical suite "form"
  #
  # @param suite [Suite] the suite in question
  # @return [String] the button string
  def medical_btn_str(suite)
    "Make #{medical_str(!suite.medical)}"
  end

  # Returns a suite describing a suite based on its medical flag
  #
  # @param medical [Boolean] whether or not the suite is a medical suite
  # @return [String] the string describing it
  def medical_str(medical)
    prefix = medical ? '' : 'non-'
    "#{prefix}medical suite"
  end
end
