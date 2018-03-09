# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Housing Intent' do
  context 'student' do
    it 'can be indicated' do
      student = FactoryGirl.create(:student_in_draw)
      student.draw.update(status: 'pre_lottery')
      log_in student
      declare_off_campus student
      expect(page).to have_css('.user-intent', text: 'Off campus')
    end

    def declare_off_campus(student)
      visit "users/#{student.id}/intent"
      select('Off campus', from: 'user_intent')
      click_on 'Submit Intent'
    end
  end

  context 'admin' do
    let!(:draw) { FactoryGirl.create(:draw, status: 'pre_lottery') }

    it 'can lock intent changes on a per draw basis' do
      student = FactoryGirl.create(:student, draw: draw)
      lock_intent(draw)
      log_in student
      expect(page).not_to have_content('Update Housing Intent')
    end

    def lock_intent(draw)
      log_in FactoryGirl.create(:admin)
      visit draw_path(draw)
      click_on 'Lock Intents'
      click_on 'Logout'
    end
  end
end
