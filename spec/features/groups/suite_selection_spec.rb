# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite Selection' do
  context 'valid' do
    let(:leader) do
      create(:draw_in_selection,
             suite_selection_mode: 'student_selection').next_groups.first.leader
    end

    it 'can be performed by group leaders' do
      suite = leader.draw.suites.where(size: leader.group.size).first
      log_in leader
      select_suite(suite.number, leader.group.id)
      expect(page).to have_content('Suite assignment successful')
    end

    def select_suite(number, group_id)
      click_on 'Select Suite'
      select number, from: "suite_assignment_suite_id_for_#{group_id}"
      click_on 'Assign suites'
    end
  end

  context 'draw not in suite selection' do
    let(:leader) do
      FactoryGirl.create(:open_group).leader.tap do |l|
        l.update(password: 'password')
        l.reload
      end
    end

    it 'link does not show' do
      log_in leader
      expect(page).not_to have_content('Select Suite')
    end

    it 'cannot reach page' do
      log_in leader
      visit new_group_suite_assignment_path(leader.group)
      expect(page).to have_content("don't have permission")
    end
  end

  context 'admin mode' do
    let(:leader) do
      FactoryGirl.create(:draw_in_selection, suite_selection_mode:
                  'admin_selection')
                 .next_groups.first.leader.tap do |l|
        l.update(password: 'password')
      end
    end

    it 'link does not show' do
      log_in leader
      expect(page).not_to have_content('Select Suite')
    end

    it 'cannot reach page' do
      log_in leader
      visit new_group_suite_assignment_path(leader.group)
      expect(page).to have_content("don't have permission")
    end
  end

  context 'not next group' do
    # TODO: fix this
    xit 'WRITE'
  end
end
