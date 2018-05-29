# frozen_string_literal: true

# Base class for all Record classes
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  private

  def handle_abort(msg)
    errors.add(:base, msg)
    throw(:abort)
  end
end
