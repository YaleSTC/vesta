# frozen_string_literal: true
#
# Helper module for drawless groups
module DrawlessGroupsHelper
  def suite_collection(group)
    available = Suite.available.order(:number).to_a
    return available unless group.suite
    available.insert(0, group.suite)
  end

  def suite_str(group)
    return "Suite: #{group.suite.number}" if group.suite.present?
    'Assign suite'
  end
end
