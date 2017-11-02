# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Students accepting clip invitations' do
  it 'succeeds' do
    clip, leader = create_clip_with_invitation
    log_in leader
    visit clip_path(clip)
    click_on 'Accept Invitation'
    expect(page).to have_content("joined #{clip.name}.")
  end

  def create_clip_with_invitation
    clip = FactoryGirl.create(:clip)
    group = FactoryGirl.create(:group_from_draw, draw: clip.draw)
    FactoryGirl.create(:clip_membership, clip: clip, group: group,
                                         confirmed: false)
    [clip, group.leader]
  end
end
