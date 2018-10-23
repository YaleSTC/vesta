# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Students accepting clip invitations' do
  it 'succeeds from the clip page' do
    clip, leader = create_clip_with_invitation
    log_in leader
    visit clip_path(clip)
    click_on 'Accept Invitation'
    expect(page).to have_content("joined #{clip.name}.")
  end

  it 'displays clip invitations on the group page' do
    _clip, leader = create_clip_with_invitation
    log_in leader
    visit group_path(leader.group)
    expect(page).to have_content('Clip (Accept Invitation / Reject Invitation)')
  end

  def create_clip_with_invitation
    clip = create(:clip)
    group = create(:group_from_draw, draw: clip.draw)
    create(:clip_membership, clip: clip, group: group, confirmed: false)
    [clip, group.leader]
  end
end
