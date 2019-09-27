# frozen_string_literal: true

# Policy for Masquerading
class MasqueradePolicy < ApplicationPolicy
  def new?
    user.admin?
  end

  def end?
    true
  end
end
