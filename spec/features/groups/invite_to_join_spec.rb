# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Students Joining Groups' do
  context 'requesting to join open group' do
    it 'succeeds' do
      group = FactoryGirl.create(:open_group, size: 2)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      log_in group.leader
      invite_member(user: user, group: group)
      expect(page).to have_content('Successfully created memberships')
    end

    def invite_member(user:, group:)
      visit draw_group_path(group.draw, group)
      click_on 'Invite Members'
      select user.full_name, from: 'group_invitations'
      click_on 'Send Invitations'
    end
  end
end
