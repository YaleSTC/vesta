# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw intent report' do
  let(:draw) { FactoryGirl.create(:draw, status: 'pre_lottery') }
  let(:f) { "vesta_intents_export_#{Time.zone.today.to_s(:number)}.csv" }
  let(:h_str) { 'email,last_name,first_name,intent' }

  context 'as an admin' do
    before { log_in(FactoryGirl.create(:admin)) }

    it 'displays a table with intent data' do
      student = create_student_data(draw: draw, intents: %w(on_campus))
      visit draw_path(draw)
      click_link('View intent report')
      expect(page_has_intent_report(page, student)).to be_truthy
    end

    it 'can export data to CSV' do
      data = create_student_data(draw: draw, intents: %w(on_campus off_campus))
      visit report_draw_intents_path(draw)
      click_link('Export to CSV')
      expect(page_is_valid_export?(page: page, data: data,
                                   filename: f, header_str: h_str)).to be_truthy
    end

    it 'csv export raises an error if no data is created' do
      visit report_draw_intents_path(draw)
      click_link('Export to CSV')
      msg = 'Data must exist before it can be exported.'
      expect(page).to have_css('.flash-error', text: /#{msg}/)
    end

    # rubocop:disable ExampleLength
    it 'can import intents for students in the draw' do
      draw = create(:draw_with_members, students_count: 3)
      User.first.update!(email: 'email1@email.com')
      User.second.update!(email: 'email2@email.com')
      User.third.update!(email: 'email3@email.com')
      visit report_draw_intents_path(draw)
      attach_file('intents_import_form[file]',
                  Rails.root.join('spec', 'fixtures', 'intent_upload.csv'))
      click_on('Import')
      # email1@email.com is already taken by the admin logging in so only two
      # of the three users will be updated from the csv
      expect(page).to have_css('.flash-success',
                               text: 'Successfully updated 2 intents.')
    end
  end

  context 'as a rep' do
    before { log_in(FactoryGirl.create(:student, role: 'rep')) }

    it 'does not display form' do
      create_student_data(draw: draw, intents: %w(on_campus))
      visit draw_path(draw)
      click_link('View intent report')
      expect(page).to have_css('td[data-role="student-intent"]')
    end
  end

  def create_student_data(draw:, intents: %w(on_campus))
    students = intents.map do |intent|
      FactoryGirl.create(:student, draw: draw, intent: intent)
    end
    return students.first if students.length == 1
    students
  end

  def page_has_intent_report(page, student)
    page_has_intent_report_heading(page) &&
      page_has_appropriate_row(page, student.intent) &&
      page_has_student_data(page, student) &&
      page_has_intent_update_form(page, student)
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

  def export_row_for(student)
    [
      student.email, student.last_name, student.first_name,
      student.intent
    ].join(',')
  end
end
