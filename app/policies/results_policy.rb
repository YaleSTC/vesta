# frozen_string_literal: true

# Policy for results
# rubocop:disable StructInheritance
class ResultsPolicy < Struct.new(:user, :results)
  def show?
    user.admin?
  end
end
