# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw intent report' do
  let(:draw) { FactoryGirl.create(:draw, status: 'pre_lottery') }

  it 'displays a table with intent data' do
    student = create_student_data(draw: draw, intents: %w(on_campus))
    log_in(FactoryGirl.create(:admin))
    visit draw_path(draw)
    click_link('View intent report')

    expect(page_has_intent_report(page, student)).to be_truthy
  end

  it 'can be filtered by status' do # rubocop:disable RSpec/ExampleLength
    student, other =
      create_student_data(draw: draw, intents: %w(on_campus off_campus))
    log_in(FactoryGirl.create(:admin))
    visit intent_report_draw_path(draw)
    filter_by_intent('on_campus')
    expect(page_has_filtered_report(page, student, other)).to be_truthy
  end

  it 'ignores empty filter requests' do # rubocop:disable RSpec/ExampleLength
    student, other =
      create_student_data(draw: draw, intents: %w(on_campus off_campus))
    log_in(FactoryGirl.create(:admin))
    visit intent_report_draw_path(draw)
    click_on 'Filter'
    expect(page_has_unfiltered_report(page, student, other)).to be_truthy
  end

  it 'does not display form when rep' do
    create_student_data(draw: draw, intents: %w(on_campus))
    log_in(FactoryGirl.create(:student, role: 'rep'))
    visit draw_path(draw)
    click_link('View intent report')
    expect(page).to have_css('td[data-role="student-intent"]')
  end

  def create_student_data(draw:, intents: %w(on_campus))
    students = intents.map do |intent|
      FactoryGirl.create(:student, draw: draw, intent: intent)
    end
    return students.first if students.length == 1
    students
  end

  def filter_by_intent(intent)
    check(intent)
    click_on 'Filter'
  end

  def page_has_intent_report(page, student)
    page_has_intent_report_heading(page) &&
      page_has_appropriate_row(page, student.intent) &&
      page_has_student_data(page, student) &&
      page_has_intent_update_form(page, student)
  end

  def page_has_filtered_report(page, student, other_student)
    page_has_student_data(page, student) &&
      page_has_no_student_data(page, other_student)
  end

  def page_has_unfiltered_report(page, student, other_student)
    page_has_student_data(page, student) &&
      page_has_student_data(page, other_student)
  end

  def page_has_intent_report_heading(page)
    page.assert_selector(:css, 'h1', text: /Intent Report/)
  end

  def page_has_appropriate_row(page, intent)
    page.assert_selector(:css, "tr.#{intent}")
  end

  def page_has_student_data(page, student)
    page.assert_selector(:css, 'td[data-role="student-first_name"]',
                         text: student.first_name)
  end

  def page_has_no_student_data(page, student)
    page.refute_selector(:css, 'td[data-role="student-first_name"]',
                         text: student.first_name)
  end

  def page_has_intent_update_form(page, student)
    page.assert_selector(:css, "td.intent-form#intent-form-#{student.id} form")
  end
end
