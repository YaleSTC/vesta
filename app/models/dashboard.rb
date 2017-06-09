# frozen_string_literal: true

# Delegator class to allow for different permissions through Pundit for the
# DashboardsController.
class Dashboard < SimpleDelegator
  # Specify the alternative policy for special groups for Pundit
  def self.policy_class
    DashboardPolicy
  end
end
