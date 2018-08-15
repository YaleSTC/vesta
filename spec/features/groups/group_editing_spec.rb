# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group editing' do
  let(:group) { create(:group) }

  before do
    group.draw.update(status: 'group_formation')
    log_in group.leader
  end
  it 'succeeds' do
    new_suite = create(:suite_with_rooms, rooms_count: 5,
                                          draws: [group.draw])
    visit edit_draw_group_path(group.draw, group)
    update_group_size(new_suite.size)
    expect(page).to have_css('.group-size', text: new_suite.size)
  end

  context 'leader update' do
    let(:new_leader) do
      create(:student, intent: 'on_campus', draw: group.draw)
    end

    before do
      create(:suite_with_rooms, rooms_count: 2, draws: [group.draw])
      group.update(size: 2)
      group.update_status!
      group.members << new_leader
    end
    it 'can be performed' do
      visit edit_draw_group_path(group.draw, group)
      select_new_leader(new_leader)
      expect(page).to have_css('.group-name', text: /#{new_leader.full_name}/)
    end
  end

  def update_group_size(new_size)
    select new_size, from: 'group_size'
    click_on 'Save'
  end

  def select_new_leader(new_leader)
    select new_leader.full_name, from: 'group_leader_id'
    click_on 'Save'
  end
end
