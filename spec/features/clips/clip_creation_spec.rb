# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip creation' do
  let(:draw) { FactoryGirl.create(:draw, status: 'pre_lottery') }
  let(:groups) { FactoryGirl.create_pair(:group_from_draw, draw: draw) }

  context 'as a leader' do
    before { log_in groups.first.leader }

    it 'succeeds' do
      visit draw_path(groups.first.draw)
      click_link('Create a clip')
      create_clip_with_groups(groups: [groups.last])
      msg = 'Clip created'
      expect(page).to have_css('.flash-success', text: /#{msg}/)
    end
  end

  context 'as a housing rep' do
    before do
      rep = create(:group_from_draw, draw: draw).leader
      rep.update(role: 'rep')
      log_in rep
    end

    it 'succeeds while adding themselves to the clip' do
      visit draw_path(groups.first.draw)
      click_link('Create a clip')
      create_clip_with_groups(groups: [groups.last], add_self_as_rep: true)
      msg = 'Clip created'
      expect(page).to have_css('.flash-success', text: /#{msg}/)
    end

    it 'fails while not adding enough groups' do
      visit draw_path(groups.first.draw)
      click_link('Create a clip')
      create_clip_with_groups(groups: [groups.last], add_self_as_rep: false)
      expect(page).to have_text('There must be more than one group per clip')
    end
  end

  context 'as an admin' do
    before { log_in FactoryGirl.create(:admin) }

    it 'succeeds' do
      visit draw_path(groups.first.draw)
      click_link('Create a clip')
      create_clip_with_groups(groups: groups)
      msg = 'Clip created'
      expect(page).to have_css('.flash-success', text: /#{msg}/)
    end
  end

  def create_clip_with_groups(groups:, add_self_as_rep: false)
    groups.each { |g| check "new_clip_form_group_ids_#{g.id}" }
    check 'new_clip_form_add_self' if add_self_as_rep
    click_on 'Create'
  end
end
