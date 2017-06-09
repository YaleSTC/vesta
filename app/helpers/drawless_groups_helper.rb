# frozen_string_literal: true

# Helper module for drawless groups
module DrawlessGroupsHelper
  def suite_str(group)
    return "Suite: #{group.suite.number}" if group.suite.present?
    'Assign suite'
  end
end
