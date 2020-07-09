# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip update' do
  before do
    log_in create(:user, role: 'superuser')
    draw = create(:draw)
    new_group = create(:group_from_draw, draw: draw)
    clip = create(:clip, draw: draw)
    visit admin_clips_path
    click_clip_edit(clip, new_group)
  end

  it 'succeeds' do
    click_on 'Save'
    expect(page).to have_content('Clip was successfully updated.')
  end
end

def click_clip_edit(clip, new_group)
  find("a[href='#{edit_admin_clip_path(clip.id)}']").click
  select(new_group.name, from: 'Groups')
end
