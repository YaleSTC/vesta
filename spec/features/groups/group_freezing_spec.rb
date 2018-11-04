# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group locking' do
  context 'admin' do
    let(:group) { create(:group) }

    before do
      group.draw.update(status: 'group_formation')
      group.draw.update(name: 'new_draw')
      log_in create(:admin)
    end
    it 'navigates to view from dashboard' do
      first(:link, group.draw.name).click
      first("a[href='#{draw_path(group.draw.id)}#{group_path(group.id)}']")
        .click
      click_on 'Begin Locking Process for Group'
      expect(page).to have_content("#{group.name} is being finalized.")
    end
  end

  context 'suite size still available, full group' do
    it 'can be initiated by a leader' do
      group = full_group(size: 2)
      log_in group.leader
      visit draw_group_path(group.draw, group)
      click_on 'Begin Locking Process for Group'
      expect(locks_leader_and_finalizes_group(group: group)).to be_truthy
    end
    it 'can be confirmed by a member' do
      group = create(:finalizing_group, size: 2)
      log_in group.members.last
      visit draw_group_path(group.draw, group)
      click_on 'Lock Membership'
      expect(group.reload).to be_locked
    end

    def locks_leader_and_finalizes_group(group:)
      group.reload
      (group.locked_members - [group.leader]).empty? && group.finalizing?
    end
  end
  context 'as admin, full group' do
    it 'can be locked' do
      group = full_group(size: 2)
      log_in create(:admin)
      visit draw_group_path(group.draw, group)
      click_on 'Lock Group'
      expect(group.reload).to be_locked
    end

    it 'can be unlocked' do
      group = create(:locked_group)
      log_in create(:admin)
      visit draw_group_path(group.draw, group)
      click_on 'Unlock All Members'
      expect(page).to have_css('.group-status', text: 'Full')
    end
  end

  def full_group(size: 2)
    create(:full_group, size: size).tap { |g| g.draw.group_formation! }
  end
end
