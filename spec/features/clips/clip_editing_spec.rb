# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip editing' do
  let!(:draw) { create(:draw, status: 'group_formation') }
  let!(:clip) { create(:clip, groups_count: 3, draw: draw) }
  let(:group_ids) { clip.group_ids }

  before { log_in create(:admin) }

  it 'navigates to view from dashboard' do
    msg = "Edit #{clip.leader.full_name}'s Clip"
    first(:link, draw.name).click
    first("a[href='#{clip_path(clip.id)}']").click
    click_on 'Edit'
    expect(page).to have_text(msg)
  end

  it 'succeeds in adding a group' do
    new_group = create(:group_from_draw, draw: clip.draw)
    visit edit_clip_path(clip)
    check_boxes(group_ids + [new_group.id])
    click_on 'Save'
    expect(page).to have_css('.flash-notice', text: /Clip updated./)
  end

  it 'succeeds in removing a group' do
    visit edit_clip_path(clip)
    uncheck "clip_group_ids_#{group_ids[0]}"
    click_on 'Save'
    expect(page).to have_css('.flash-notice', text: /Clip updated./)
  end

  it 'fails if too few groups are given' do
    visit edit_clip_path(clip)
    uncheck_boxes(group_ids)
    click_on 'Save'
    msg = 'There must be more than one group per clip. '
    expect(page).to have_css('.flash-error', text: /#{msg}/)
  end

  def check_boxes(group_ids)
    group_ids.each do |id|
      check "clip_group_ids_#{id}"
    end
  end

  def uncheck_boxes(group_ids)
    group_ids.each do |id|
      uncheck "clip_group_ids_#{id}"
    end
  end
end
