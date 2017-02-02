# frozen_string_literal: true
#
# Helper module for drawless groups
module DrawlessGroupsHelper
  def suite_collection(group)
    available = Suite.available.to_a
    return available unless group.suite
    available.insert(0, group.suite)
  end
end
