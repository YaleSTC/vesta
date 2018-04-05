# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw suite selection' do
  let(:clip) { create(:locked_clip) }
  let(:draw) { clip.draw }
  let(:group) { create(:locked_group, :defined_by_draw, draw: draw) }
  let!(:clip_suites) do
    clip.groups.map { |g| create(:suite_with_rooms, rooms_count: g.size) }
  end
  let!(:other_suite) { create(:suite_with_rooms, rooms_count: group.size) }
  let(:f) { "vesta_groups_export_#{Time.zone.today.to_s(:number)}.csv" }
  let(:h_str) { 'name,lottery_number,suite_number' }

  before do
    draw.suites << clip_suites << other_suite
    draw.lottery!
    create(:lottery_assignment, :defined_by_clip, clip: clip, number: 1)
    create(:lottery_assignment, :defined_by_group, group: group, number: 2)
    draw.suite_selection!
  end

  context 'as admin' do
    before { log_in FactoryGirl.create(:admin) }

    it 'can be done' do
      visit draw_path(draw)
      click_on 'Select suites'
      assign_suites(clip.groups, clip_suites)
      assign_suites([group], [other_suite])
      expect(page).to have_css('.flash-success', text: /All groups have suites/)
    end

    it 'permits disbanding of groups' do
      visit new_draw_suite_assignment_path(draw)
      within("#group-fields-#{clip.groups.first.id}") do
        click_on 'Disband Group'
      end
      expect(page).to have_css('.flash-notice', text: /Group.+deleted/)
    end

    it 'creates secondary draws if necessary' do
      group.destroy!
      visit draw_path(draw)
      click_on 'Select suites'
      assign_suites(clip.groups, clip_suites)
      expect(page).to have_css('.flash-notice', text: /draw has been created/)
    end

    it 'has option to remove selected suites' do
      visit new_draw_suite_assignment_path(draw)
      assign_suites(clip.groups, clip_suites)
      visit draw_group_path(draw, clip.groups.first)
      expect(page).to have_button('Remove suite')
    end

    it 'shows the disband button when there are not enough suites' do
      draw.suites.where.not(id: clip_suites.first.id).delete_all
      visit new_draw_suite_assignment_path(draw)
      expect(page).to have_link('Disband')
    end

    it 'moves to the result phase when there are no more groups to assign' do
      # This leaves one group unassigned with no suites available
      draw.groups.where.not(id: group.id).each(&:destroy!)
      draw.suites.delete_all
      visit new_draw_suite_assignment_path(draw)
      click_on 'Disband Group'
      expect(page).to have_css('.flash-success', text: /All groups have suites/)
    end

    it 'can export lottery assignment information' do
      visit draw_path(draw)
      click_on 'Export Lottery Numbers'
      expect(page_is_valid_export?(page: page, data: draw.groups,
                                   filename: f, header_str: h_str)).to be_truthy
    end

    def assign_suites(groups, suites)
      groups.each_with_index do |group, i|
        select suites[i].name, from: "suite_assignment_suite_id_for_#{group.id}"
      end
      click_on 'Assign suites'
    end
  end

  context 'as rep' do
    before { log_in FactoryGirl.create(:user, role: 'rep') }

    it 'can view draw page' do
      visit draw_path(draw)
      expect(page).to have_content(draw.name)
    end
  end

  context 'as student in group' do
    before { log_in clip.groups.first.leader }

    it 'can view draw page' do
      visit draw_path(draw)
      expect(page).to have_content(draw.name)
    end
  end

  def export_row_for(group)
    [group.name, group.lottery_number, group.suite_number].join(',')
  end
end
