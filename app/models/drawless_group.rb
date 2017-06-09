# frozen_string_literal: true

# Delegator class to allow for different permissions through Pundit for the
# SpecialGroupsController.
class DrawlessGroup < SimpleDelegator
  # Specify the alternative policy for special groups for Pundit
  def self.policy_class
    DrawlessGroupPolicy
  end
end
