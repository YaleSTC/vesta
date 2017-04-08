# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite Selection' do
  context 'valid' do
    let(:leader) do
      FactoryGirl.create(:draw_in_selection, suite_selection_mode:
                  'student_selection')
                 .next_groups.first.leader.tap do |l|
        l.update(password: 'password')
      end
    end

    it 'can be performed by group leaders' do
      suite = leader.draw.suites.where(size: leader.group.size).first
      log_in leader
      select_suite(suite.number)
      expect(page).to have_content("#{suite.number} assigned")
    end

    def select_suite(number)
      click_on 'Select Suite'
      choose number
      click_on 'Submit Selection'
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
      visit select_suite_draw_group_path(leader.draw, leader.group)
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
      visit select_suite_draw_group_path(leader.draw, leader.group)
      expect(page).to have_content("don't have permission")
    end
  end

  context 'not next group' do
    xit 'WRITE'
  end
end
