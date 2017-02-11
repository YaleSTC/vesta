# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Group locking' do
  context 'suite size still available, full group' do
    it 'can be initiated by a leader' do
      group = FactoryGirl.create(:full_group, size: 2)
      log_in group.leader
      visit draw_group_path(group.draw, group)
      click_on 'Finalize Group'
      expect(locks_leader_and_finalizes_group(group: group)).to be_truthy
    end
    it 'can be confirmed by a member' do
      group = FactoryGirl.create(:finalizing_group, size: 2)
      log_in group.members.last
      visit draw_group_path(group.draw, group)
      click_on 'Finalize Membership'
      expect(group.reload).to be_locked
    end

    def locks_leader_and_finalizes_group(group:)
      group.reload
      (group.locked_members - [group.leader]).empty? && group.finalizing?
    end
  end
  context 'as admin, full group' do
    it 'can be locked' do
      group = FactoryGirl.create(:full_group, size: 2)
      log_in FactoryGirl.create(:admin)
      visit draw_group_path(group.draw, group)
      click_on 'Lock Group'
      expect(group.reload).to be_locked
    end
  end
end
