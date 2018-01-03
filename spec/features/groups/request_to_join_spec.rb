# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Students Joining Groups' do
  context 'requesting to join open group' do
    it 'succeeds' do
      group = FactoryGirl.create(:open_group)
      log_in FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      visit draw_group_path(group.draw, group)
      click_on 'Request To Join'
      expect(page).to have_content(/Membership.+created/)
    end
  end

  context 'requesting to join a full group' do
    it 'fails' do
      group = FactoryGirl.create(:full_group).tap { |g| g.draw.pre_lottery! }
      log_in FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      visit draw_group_path(group.draw, group)
      click_on 'Request To Join'
      expect(page).to have_content('Please review the errors below:')
    end
  end

  context 'approving requests' do
    it 'succeeds' do # rubocop:disable RSpec/ExampleLength
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      Membership.create(group: group, user: user, status: 'requested')
      log_in group.leader
      visit draw_group_path(group.draw, group)
      click_on 'accept'
      expect(page).to have_content("#{user.full_name} joined group")
    end
  end

  context 'rejecting requests' do
    it 'succeeds' do # rubocop:disable RSpec/ExampleLength
      group = FactoryGirl.create(:open_group)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      Membership.create(group: group, user: user, status: 'requested')
      log_in group.leader
      visit draw_group_path(group.draw, group)
      click_on 'reject'
      expect(page).to have_content("#{user.full_name}'s membership deleted")
    end
  end
end
