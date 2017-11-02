# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip editing' do
  let(:clip) { FactoryGirl.create(:clip, groups_count: 3) }

  before { log_in FactoryGirl.create(:admin) }

  it 'succeeds in adding a group' do
    new_group = FactoryGirl.create(:group_from_draw, draw: clip.draw)
    visit edit_clip_path(clip)
    check "clip_group_ids_#{new_group.id}"
    click_on 'Save'
    expect(page).to have_css('.flash-notice', text: /#{clip.name} updated./)
  end

  it 'succeeds in removing a group' do
    visit edit_clip_path(clip)
    uncheck "clip_group_ids_#{clip.groups.last.id}"
    click_on 'Save'
    expect(page).to have_css('.flash-notice', text: /#{clip.name} updated./)
  end

  it 'fails if too few groups are given' do
    visit edit_clip_path(clip)
    clip.groups.each { |group| uncheck "clip_group_ids_#{group.id}" }
    click_on 'Save'
    msg = 'There must be more than one group per clip. '
    expect(page).to have_css('.flash-error', text: /#{msg}/)
  end
end
