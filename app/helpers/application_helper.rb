# frozen_string_literal: true

# General view helper module
module ApplicationHelper
  delegate :size_str, to: Suite

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

  # Return a pluralized and capitalized named version of a suite / group size
  #
  # @param size [Integer] the suite / group size
  # @return [String] the appropriate name
  def headerize_size(size)
    size_str(size).pluralize.capitalize
  end

  # Return the correct path for settings - creates a new College if one doesn't
  # exist
  #
  # @param college [College] the current_college, may not be persisted
  # @return [String] the appropriate link
  def settings_path(college)
    return edit_college_path(college) if college.id
    new_college_path
  end

  # Returns the full title on a per-page basis.
  #
  # @param page_title [String] the specific page title
  # @return [String] the overall page title
  def full_title(page_title = '')
    base_title = 'Vesta'
    if page_title.empty?
      base_title
    else
      page_title + ' | ' + base_title
    end
  end
end
