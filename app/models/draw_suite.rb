# frozen_string_literal: true

# Intermediary model for draws <--> suites, originally a has_and_belongs_to_many
# association but now has_many :through
class DrawSuite < ApplicationRecord
  belongs_to :draw
  belongs_to :suite
end
