# frozen_string_literal: true
# Model for Tags, which can be added to suites.
#
# @attr [String] name The name of the tag.
# @attr [Array<Suite>] suites The tagged suites.
class Tag < ApplicationRecord
  validates :name, presence: true
end
