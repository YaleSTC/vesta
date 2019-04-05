# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Housing Intent' do
  context 'student' do
    it 'can be indicated' do
      student = create(:student_in_draw)
      student.draw.update(status: 'group_formation')
      log_in student
      declare_off_campus student
      expect(page).to have_css('.user-intent', text: 'Off campus')
    end

    it 'displays "Intent updated." on success' do
      student = create(:student_in_draw)
      student.draw.update(status: 'group_formation')
      log_in student
      declare_off_campus student
      expect(page).to have_content('Intent updated.')
    end

    def declare_off_campus(student)
      visit "users/#{student.id}/intent"
      select('Off campus', from: 'user_intent')
      click_on 'Submit Intent'
    end
  end

  context 'admin' do
    let!(:draw) { create(:draw, status: 'group_formation') }

    it 'can lock intent changes on a per draw basis' do
      student = create(:student_in_draw, draw: draw)
      lock_intent(draw)
      log_in student
      expect(page).not_to have_content('Update Housing Intent')
    end

    def lock_intent(draw)
      log_in create(:admin)
      visit draw_path(draw)
      click_on 'Lock Intents'
      click_on 'Log Out'
    end
  end
end
