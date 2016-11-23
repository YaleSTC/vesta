# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw Creation' do
  before { log_in FactoryGirl.create(:admin) }
  it 'succeeds' do
    student = FactoryGirl.create(:student, first_name: 'Sydney')
    suite = FactoryGirl.create(:suite)
    name = 'Sophomore Draw'
    create_draw(name: name, students: [student], suites: [suite])
    expect(page).to have_css('.draw-name', text: name)
  end
  it 'redirects to /new on failure' do
    visit 'draws/new'
    click_on 'Create'
    expect(page).to have_content('New Draw')
  end

  def create_draw(name:, students:, suites:)
    visit 'draws/new'
    fill_in 'draw_name', with: name
    select_draw_members(students: students, suites: suites)
    click_on 'Create'
  end

  def select_draw_members(students:, suites:)
    students.each { |s| select s.name, from: 'draw_student_ids' }
    suites.each { |s| select s.number, from: 'draw_suite_ids' }
  end
end
