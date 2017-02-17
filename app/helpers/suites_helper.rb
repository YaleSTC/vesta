# frozen_string_literal: true
#
# Helper module for Suites
module SuitesHelper
  # Generates a deactivation link for active suites and an activation link for
  # inactive suites.
  #
  # @param suite [Suite] the suite in question
  # @return [String] the appropriate link
  def activation_link(suite)
    action = suite.active? ? 'deactivate' : 'activate'
    link_text = action.titleize
    target_method = "#{action}_suite_path".to_sym
    link_to link_text, send(target_method, suite), method: :patch
  end
end
