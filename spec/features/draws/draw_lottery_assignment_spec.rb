# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw lottery assignment', js: true do
  context 'as admin' do
    let(:clip) { create(:locked_clip) }
    let(:draw) { clip.draw }
    let!(:group) { create(:locked_group, :defined_by_draw, draw: draw) }

    before do
      draw.lottery!
      log_in FactoryGirl.create(:admin)
    end

    it 'can be performed' do # rubocop:disable RSpec/ExampleLength
      visit draw_path(draw)
      click_on 'Assign lottery numbers'
      assign_lottery_number(object: clip, number: 1)
      assign_lottery_number(object: group, number: 2)
      reload
      expectation = lottery_number_saved?(object: clip, number: 1) &&
                    lottery_number_saved?(object: group, number: 2)
      expect(expectation).to be_truthy
    end

    it 'can be changed' do
      FactoryGirl.create(:lottery_assignment, draw: draw, groups: [group])
      visit draw_lottery_assignments_path(draw)
      assign_lottery_number(object: group, number: 6)
      reload
      expect(lottery_number_saved?(object: group, number: 6)).to be_truthy
    end

    def assign_lottery_number(object:, number:)
      within(selector(object)) do
        fill_in 'lottery_assignment_number', with: number.to_s
        find(:css, '#lottery_assignment_number').send_keys(:tab)
      end
    end

    def selector(object)
      class_str = object.class.to_s.downcase
      "\#lottery-form-#{class_str}-#{object.id}"
    end

    def reload
      page.evaluate_script('window.location.reload()')
    end

    def lottery_number_saved?(object:, number:)
      within(selector(object)) do
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
