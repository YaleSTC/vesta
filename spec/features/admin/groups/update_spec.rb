# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Admin dashboard group update' do
  let(:group) { create(:group) }

  before do
    log_in create(:user, role: 'superuser')
    create(:student_in_draw, role: 'student')
  end

  it 'respects size validations (rejecting size = 0)' do
    visit edit_admin_group_path(group.id)
    fill_in 'group_size', with: 0
    click_on 'Save'
    expect(page).to have_content('Group update failed')
  end

  context 'when changing leaders' do
    let(:new_leader) do
      create(:student_in_draw, intent: 'on_campus', draw: group.draw)
    end

    before do
      create(:suite_with_rooms, rooms_count: 2, draws: [group.draw])
      group.update(size: 2)
      group.update_status!
      create(:membership, group: group, user: new_leader)
    end

    it 'can be performed' do
      visit edit_admin_group_path(group.id)
      select new_leader.full_name, from: 'group_leader_id'
      click_on 'Save'
      expect(page).to have_content("#{new_leader.full_name}'s Group")
    end
  end
end
