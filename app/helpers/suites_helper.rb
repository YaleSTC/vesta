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

  # Return a suite's availability status
  #
  # @return [String] the status "Available" or "Unavailable" with assignment
  def status_string(suite, user)
    group = suite.group
    if suite.available?
      'Available'
    elsif suite.medical || group.draw.nil?
      user.admin? ? group_unavailable_string(group) : 'Unavailable'
    else
      drawless_group_unavailable_string(group)
    end
  end

  def group_unavailable_string(group)
    # rubocop:disable Rails/OutputSafety
    "Unavailable (Assigned to #{link_to group.name, group_path(group)})"
      .html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def drawless_group_unavailable_string(group)
    # rubocop:disable Rails/OutputSafety
    'Unavailable (Assigned to ' \
    "#{link_to group.name, draw_group_path(group.draw, group)})"
      .html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
