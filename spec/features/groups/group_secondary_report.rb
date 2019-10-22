# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group secondary report' do
  let(:draw) { create(:draw) }
  let(:groups) { create_list(:locked_group, 3, :defined_by_draw, draw: draw) }

  before do
    log_in create(:admin)
    groups
  end

  describe 'table with group ordering' do
    before do
      visit draw_path(draw)
      click_on 'Proceed to lottery confirmation'
      click_on 'Proceed to lottery'
      click_on 'Automatically assign lottery numbers'
    end

    it 'displays the group with lottery number 1 before 2' do
      first_index = page.body =~ /.*td data-role="group-lottery">1<.*/
      second_index = page.body =~ /.*td data-role="group-lottery">2<.*/
      expect(first_index).to be < second_index
    end

    it 'displays the group with lottery number 2 before 3' do
      second_index = page.body =~ /.*td data-role="group-lottery">2<.*/
      third_index = page.body =~ /.*td data-role="group-lottery">3<.*/
      expect(second_index).to be < third_index
    end
  end
end
