# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Students leaving clips' do
  it 'succeeds' do
    clip, leader = create_clip_and_leader
    log_in leader
    visit clip_path(clip)
    click_on 'Leave Clip'
    expect(page).to have_content('Successfully left clip.')
  end

  def create_clip_and_leader
    clip = FactoryGirl.create(:clip)
    group = FactoryGirl.create(:group_from_draw, draw: clip.draw)
    FactoryGirl.create(:clip_membership, clip: clip, group: group,
                                         confirmed: true)
    [clip, group.leader]
  end
end
