# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw student assignment' do
  let(:draw) { FactoryGirl.create(:draw) }
  before { log_in FactoryGirl.create(:admin) }
  describe 'bulk adding' do
    before { FactoryGirl.create_pair(:student, class_year: 2016) }
    it 'can be performed' do
      visit draw_path(draw)
      click_on 'View student'
      bulk_assign_students(2016)
      message = 'Students successfully updated'
      expect(page).to have_css('.flash-success', text: message)
    end

    def bulk_assign_students(year)
      select year.to_s, from: 'draw_students_update_class_year'
      click_on 'Assign students'
    end
  end
end
