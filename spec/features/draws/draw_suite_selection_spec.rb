# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw suite selection' do
  let(:draw) { FactoryGirl.create(:draw_in_selection, groups_count: 2) }
  let(:groups) { draw.groups.order_by_lottery }
  let(:suites) { draw.suites }

  context 'as admin' do
    before { log_in FactoryGirl.create(:admin) }

    it 'can be done by admins' do
      visit draw_path(draw)
      click_on 'Select suites'
      groups.each_with_index { |g, i| assign_suites(g, suites[i]) }
      expect(page).to have_css('.flash-success', text: /All groups have suites/)
    end

    it 'permits disbanding of groups' do
      draw.suites.delete_all
      visit draw_path(draw)
      click_on 'Select suites'
      # TODO: re-enable when we have clips & multiselect again
      # within("#group-fields-#{groups.first.id}") { click_on 'Disband' }
      click_on 'Disband'
      expect(page).to have_css('.flash-notice', text: /Group.+deleted/)
    end

    it 'creates secondary draws if necessary' do
      groups.last.destroy!
      visit draw_path(draw)
      click_on 'Select suites'
      assign_suites(groups[0], suites[0])
      expect(page).to have_css('.flash-notice', text: /draw has been created/)
    end

    it 'has option to remove selected suites' do
      visit new_draw_suite_assignment_path(draw)
      assign_suites(groups[0], suites[0])
      visit draw_group_path(draw, groups[0])
      expect(page).to have_button('Remove suite')
    end

    xit 'shows the disband button when there are not enough suites' do
      # TODO: reenable with clips
      # This creates two groups with the same lottery number and only one suite
      suites.where.not(id: suites.first.id).delete_all
      groups.second.update(lottery_number: 1)
      visit new_draw_suite_assignment_path(draw)
      expect(page).to have_link('Disband')
    end

    it 'moves to the result phase when there are no more groups to assign' do
      # This leaves one group unassigned with no suites available
      groups.where.not(id: groups.first.id).delete_all
      suites.delete_all
      visit new_draw_suite_assignment_path(draw)
      click_on 'Disband'
      expect(page).to have_css('.flash-success', text: /All groups have suites/)
    end

    def assign_suites(group, suite)
      select suite.name, from: "suite_assignment_suite_id_for_#{group.id}"
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
    before do
      student = groups.first.leader
      student.password = 'passw0rd'
      log_in student
    end

    it 'can view draw page' do
      visit draw_path(draw)
      expect(page).to have_content(draw.name)
    end
  end
end
