# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw student assignment' do
  let(:draw) { create(:draw) }

  before { log_in create(:admin) }
  describe 'bulk adding' do
    before { create_pair(:student, class_year: 2016) }
    it 'can be performed' do
      visit draw_path(draw)
      click_on 'Add or edit students'
      bulk_assign_students(2016)
      message = 'Students successfully updated'
      expect(page).to have_css('.flash-success', text: message)
    end

    def bulk_assign_students(year)
      visit edit_draw_students_path(draw)
      select year.to_s, from: 'draw_students_update_class_year'
      click_on 'Assign students'
    end
  end

  describe 'single user adding' do
    let!(:student) { create(:student, username: 'foo') }
    let!(:student_in_group) { create(:student, username: 'stu') }

    before { create(:group, leader: student_in_group) }

    it 'can be performed' do
      visit edit_draw_students_path(draw, student)
      fill_in 'draw_student_assignment_form_username', with: 'foo'
      click_on 'Process'
      message = "#{student.full_name} successfully added"
      expect(page).to have_css('.flash-success', text: message)
    end

    it 'displays user not found error if user is not imported' do
      visit edit_draw_students_path(draw)
      fill_in 'draw_student_assignment_form_username', with: 'bar'
      click_on 'Process'
      message = "Username cannot be found. Maybe you haven't imported them yet?"
      expect(page).to have_css('.flash-error', text: message)
    end

    it 'displays user in group error if user is already in a group' do
      visit edit_draw_students_path(draw)
      fill_in 'draw_student_assignment_form_username', with: 'stu'
      click_on 'Process'
      msg = 'cannot be added to this draw because they are already in a group.'
      expect(page).to have_css('.flash-error', text: msg)
    end
  end

  describe 'single user removing' do
    let(:student) { create(:student, username: 'foo') }

    before { draw.students << student }
    it 'can be performed' do
      visit edit_draw_students_path(draw, student)
      remove_user(username: 'foo')
      message = "#{student.full_name} successfully removed"
      expect(page).to have_css('.flash-success', text: message)
    end

    def remove_user(username:)
      fill_in 'draw_student_assignment_form_username', with: username
      select 'Remove'
      click_on 'Process'
    end
  end
end
