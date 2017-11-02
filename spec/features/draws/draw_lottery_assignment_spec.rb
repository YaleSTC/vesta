# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw lottery assignment', js: true do
  let(:clip) { create(:locked_clip) }
  let(:draw) { clip.draw }
  let!(:group) { create(:locked_group, :defined_by_draw, draw: draw) }

  before { draw.lottery! }

  context 'as admin' do
    before { log_in FactoryGirl.create(:admin) }

    xit 'can be performed' do # rubocop:disable RSpec/ExampleLength
      visit draw_path(draw)
      click_on 'Manually assign lottery numbers'
      assign_lottery_number(object: clip, number: 1)
      assign_lottery_number(object: group, number: 2)
      reload
      expectation = lottery_number_saved?(object: clip, number: 1) &&
                    lottery_number_saved?(object: group, number: 2)
      expect(expectation).to be_truthy
    end

    xit 'can be changed' do
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
    before { log_in create(:user, role: 'rep') }

    xit 'can view draw page with incomplete lottery' do
      visit draw_path(draw)
      expect(page).to have_content(draw.name)
    end
  end
end
