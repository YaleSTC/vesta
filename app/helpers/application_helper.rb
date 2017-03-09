# frozen_string_literal: true
# General view helper module
module ApplicationHelper
  include ActionView::Helpers::OutputSafetyHelper
  # Builds a Foundation tooltip around some content (
  #
  # @param text [String] the tooltip text
  # @param class_override [String] any additional classes to add to the base
  #   element
  # @return [Hash] a hash of attributes that can be passed to tag helpers to
  #   create a tooltip (e.g. link_to)
  def with_tooltip(text:, class_override: '', **overrides)
    {
      data: { tooltip: true, 'disable-hover' => false }, title: text,
      aria: { haspopup: true }, class: "has-tip #{class_override}"
    }.merge(**overrides)
  end
end
