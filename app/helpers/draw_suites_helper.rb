# frozen_string_literal: true

# Helper methods for the draw_suites views
module DrawSuitesHelper
  # Checks to see if there are enough open suites for all groups
  # of the current group's size
  #
  # @param group [Group] the group being assigned
  # @return [Boolean] true if there are enough suites, false otherwise
  def enough_suites_available(group)
    if @suites_by_size[group.size]
      @suites_by_size[group.size].count >= @groups_by_size[group.size].count
    else
      false
    end
  end
end
