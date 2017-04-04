# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw suite selection' do
  let(:draw) { FactoryGirl.create(:draw_in_selection, groups_count: 3) }
  let(:groups) { draw.groups.order(:lottery_number) }
  let(:suites) { draw.suites }

  context 'as admin' do
    before do
      groups.first.update(lottery_number: 1)
      log_in FactoryGirl.create(:admin)
    end

    it 'can be done by admins' do
      visit draw_path(draw)
      click_on 'Select suites'
      assign_suites(groups[0..1], suites[0..1])
      assign_suites([groups[2]], [suites[2]])
      expect(page).to have_css('.flash-success', text: /All groups have suites/)
    end

    it 'permits disbanding of groups' do
      draw.suites.delete_all
      visit draw_path(draw)
      click_on 'Select suites'
      within("#group-fields-#{groups.first.id}") { click_on 'Disband' }
      expect(page).to have_css('.flash-notice', text: /Group.+deleted/)
    end

    it 'creates secondary draws if necessary' do
      groups.last.destroy!
      visit draw_path(draw)
      click_on 'Select suites'
      assign_suites(groups[0..1], suites[0..1])
      expect(page).to have_css('.flash-notice', text: /draw has been created/)
    end

    def assign_suites(groups, suites)
      groups.each_with_index do |group, i|
        suite = suites[i]
        select suite.name,
               from: "bulk_suite_selection_form_suite_id_for_#{group.id}"
      end
      click_on 'Assign suites'
    end
  end

  context 'as rep' do
    before do
      groups.first.update(lottery_number: 1)
      log_in FactoryGirl.create(:user, role: 'rep')
    end

    it 'can view draw page' do
      visit draw_path(draw)
      expect(page).to have_content(draw.name)
    end
  end
end
