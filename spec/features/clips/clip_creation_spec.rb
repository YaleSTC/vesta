# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Clip creation', type: :feature do
  let(:draw) { create(:draw, status: 'group_formation') }
  let(:groups) { create_pair(:group_from_draw, draw: draw) }

  context 'as a leader' do
    before { log_in groups.first.leader }

    it "includes user's group in the clip creation without displaying it" do
      navigate_to_create_clip
      expect(page)
        .not_to have_css("#new_clip_form_group_ids_#{groups.first.id}")
    end

    it 'succeeds' do
      navigate_to_create_clip
      create_clip_with_groups(groups: [groups.last])
      msg = 'Clip created'
      expect(page).to have_css('.flash-success', text: /#{msg}/)
    end
  end

  context 'as a housing rep' do
    let(:rep) { create(:group_from_draw, draw: draw).leader }

    before do
      rep.update(role: 'rep')
      log_in rep
    end

    it 'allows current user to add their group to the clip' do
      visit draw_group_path(groups.first.draw, groups.first)
      click_link('Create a Clip')
      expect(page).to have_css("#new_clip_form_group_ids_#{rep.group.id}")
    end

    it 'fails while not adding enough groups' do
      visit draw_group_path(groups.first.draw, groups.first)
      click_link('Create a Clip')
      click_on 'Create'
      expect(page).to have_text('There must be more than one group per clip')
    end
  end

  context 'as an admin' do
    before { log_in create(:admin) }

    it 'succeeds' do
      visit draw_group_path(groups.first.draw, groups.first)
      click_link('Create a Clip')
      create_clip_with_group(group: groups[1])
      msg = 'Clip created'
      expect(page).to have_css('.flash-success', text: /#{msg}/)
    end
  end

  def navigate_to_create_clip
    visit draw_path(groups.first.draw)
    click_link('My Group')
    click_link('Create a Clip')
  end

  def create_clip_with_group(group:)
    check "new_clip_form_group_ids_#{group.id}"
    click_on 'Create'
  end

  def create_clip_with_groups(groups:)
    groups.each { |g| check "new_clip_form_group_ids_#{g.id}" }
    click_on 'Create'
  end
end
