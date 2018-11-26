# frozen_string_literal: true

# Model to represent suite assignments
#
# @attr suite [Suite] the suite assigned to the group
# @attr group [Group] the group assigned to the suite
class SuiteAssignment < ApplicationRecord
  belongs_to :suite
  belongs_to :group

  has_one :lottery_assignment, through: :group

  validates :suite, presence: true
  validates :group, presence: true, uniqueness: true

  after_save :update_lottery_assignment

  before_destroy :remove_room_assignments

  after_destroy :update_lottery_assignment

  private

  def update_lottery_assignment
    return unless lottery_assignment.present?
    lottery_assignment.update_selected!
  end

  def remove_room_assignments
    ActiveRecord::Base.transaction do
      suite.rooms.map(&:room_assignments).each do |room_assignments|
        room_assignments.map(&:destroy!)
      end
    end
  rescue
    handle_abort('Unable to clear room assignments')
  end
end
