# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Students Joining Groups' do
  context 'requesting to join open group' do
    it 'succeeds' do
      group = create(:open_group)
      log_in create(:student_in_draw, intent: 'on_campus', draw: group.draw)
      visit draw_group_path(group.draw, group)
      click_on 'Request To Join'
      expect(page).to have_content(/Membership.+created/)
    end

    it 'does not have extra request to join button' do
      group = create(:open_group)
      log_in create(:student_in_draw, intent: 'on_campus', draw: group.draw)
      visit draw_group_path(group.draw, group)
      click_on 'Request To Join'
      expect(page).not_to have_content(/Request To Join/)
    end

    it 'does not let you accept your own invitation' do
      group = create(:open_group)
      log_in create(:student_in_draw, intent: 'on_campus', draw: group.draw)
      visit draw_group_path(group.draw, group)
      click_on 'Request To Join'
      expect(page).not_to have_content(/Accept Invitation/)
    end
  end

  context 'requesting to join a full group' do
    it 'fails' do
      group = create(:full_group).tap { |g| g.draw.group_formation! }
      log_in create(:student_in_draw, intent: 'on_campus', draw: group.draw)
      visit draw_group_path(group.draw, group)
      click_on 'Request To Join'
      expect(page).to have_content('Please review the errors below:')
    end
  end

  context 'approving requests' do
    it 'succeeds' do # rubocop:disable RSpec/ExampleLength
      group = create(:open_group)
      user = create(:student_in_draw, intent: 'on_campus', draw: group.draw)
      create(:membership, group: group, user: user, status: 'requested')
      log_in group.leader
      visit draw_group_path(group.draw, group)
      click_on 'accept'
      expect(page).to have_content("#{user.full_name} joined group")
    end
  end

  context 'rejecting requests' do
    it 'succeeds' do # rubocop:disable RSpec/ExampleLength
      group = create(:open_group)
      user = create(:student_in_draw, intent: 'on_campus', draw: group.draw)
      create(:membership, group: group, user: user, status: 'requested')
      log_in group.leader
      visit draw_group_path(group.draw, group)
      click_on 'reject'
      expect(page).to have_content("#{user.full_name}'s membership deleted")
    end
  end
end
