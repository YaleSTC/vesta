# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Students Joining Groups' do
  context 'inviting to join open group' do
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
      check user.full_name
      click_on 'Send Invitations'
    end
  end

  context 'rescinding invitation' do
    it 'succeeds' do # rubocop:disable RSpec/ExampleLength
      group = FactoryGirl.create(:open_group, size: 2)
      user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
      Membership.create(user: user, group: group, status: 'invited')
      log_in group.leader
      visit draw_group_path(group.draw, group)
      click_on 'rescind'
      expect(page).to have_content("#{user.full_name}'s membership deleted")
    end
  end
end
