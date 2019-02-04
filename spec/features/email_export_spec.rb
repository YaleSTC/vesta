# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Email export' do
  let!(:draw) { create(:draw_with_members, status: 'group_formation') }
  let!(:group) { create(:locked_group, leader: draw.students.last, size: 2) }

  before { log_in create(:admin) }

  context 'with default options' do
    it 'returns all the group leader e-mails in a given draw' do
      select_draw(draw)
      click_on 'Get e-mails'
      expect(page).to have_content(group.leader.email)
    end
    it 'does not return extraneous emails' do
      select_draw(draw)
      click_on 'Get e-mails'
      expect(page).not_to have_content(nonleader.email)
    end
  end

  context 'with custom options' do
    it 'optionally returns all member emails, not just leaders' do
      select_draw(draw)
      uncheck 'email_export_leaders_only'
      click_on 'Get e-mails'
      expect(page).to have_content(nonleader.email)
    end
  end
end

private

def select_draw(draw)
  visit new_email_export_path
  select draw.name, from: 'email_export_draw_id'
end

# There's not a great way to generate an arbitrary nonleader aside from
# just picking the first user in a group and taking a different one if
# that happened to be the user.
def nonleader
  nonleader = group.full_memberships[0].user
  nonleader == group.leader ? group.full_memberships[1].user : nonleader
end
