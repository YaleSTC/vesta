# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw lottery assignment', js: true do
  context 'as admin' do
    let(:draw) { FactoryGirl.create(:draw_in_lottery, groups_count: 2) }
    let(:group) { draw.groups.first }

    before { log_in FactoryGirl.create(:admin) }

    it 'can be performed' do
      visit draw_path(draw)
      click_on 'Assign lottery numbers'
      assign_lottery_number(group, 1)
      reload
      expect(lottery_number_saved?(group, 1)).to be_truthy
    end

    it 'can be changed' do
      FactoryGirl.create(:lottery_assignment, draw: draw, groups: [group])
      visit draw_lottery_assignments_path(draw)
      assign_lottery_number(group, '6')
      reload
      expect(lottery_number_saved?(group, 6)).to be_truthy
    end

    def assign_lottery_number(group, number)
      within("\#lottery-form-#{group.id}") do
        fill_in 'lottery_assignment_number', with: number.to_s
        find(:css, '#lottery_assignment_number').send_keys(:tab)
      end
    end

    def reload
      page.evaluate_script('window.location.reload()')
    end

    def lottery_number_saved?(group, number)
      within("\#lottery-form-#{group.id}") do
        assert_selector(:css, "#lottery_assignment_number[value='#{number}']")
      end
    end
  end

  context 'as rep' do
    let(:draw) { FactoryGirl.create(:draw_in_lottery, groups_count: 2) }
    let(:group) { draw.groups.first }

    it 'can view draw page with incomplete lottery' do
      log_in FactoryGirl.create(:user, role: 'rep')
      visit draw_path(draw)
      expect(page).to have_content(draw.name)
    end
  end
end
