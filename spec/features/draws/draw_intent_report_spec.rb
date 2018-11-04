# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw intent report' do
  shared_examples 'draw intent report' do
    let(:f) { "vesta_intents_export_#{Time.zone.today.to_s(:number)}.csv" }
    let(:h_str) { 'email,student_id,last_name,first_name,intent' }
    let!(:draw) { create(:draw, status: 'intent_selection') }

    context 'as an admin' do
      before { log_in(create(:admin)) }

      it 'displays a table with intent data' do
        navigate_to_view
        student = create_student_data(draw: draw, intents: %w(on_campus))
        click_link('View intent report')
        expect(page_has_intent_report(page, student)).to be_truthy
      end

      it 'can export data to CSV' do
        d = create_student_data(draw: draw, intents: %w(on_campus off_campus))
        visit report_draw_intents_path(draw)
        click_link('Export to CSV')
        expect(page_is_valid_export?(page: page, data: d, filename: f,
                                     header_str: h_str)).to be_truthy
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

      def navigate_to_view
        visit root_path
        first(:link, draw.name).click
      end
    end

    context 'as a rep' do
      before { log_in(create(:student, role: 'rep')) }

      it 'does not display form' do
        create_student_data(draw: draw, intents: %w(on_campus))
        visit draw_path(draw)
        click_link('View intent report')
        expect(page).to have_css('td[data-role="student-intent"]')
      end
    end
  end

  describe 'intent-selection draw' do
    let(:draw) { create(:draw, status: 'intent_selection') }

    it_behaves_like 'draw intent report'
  end

  describe 'group-formation draw' do
    let(:draw) { create(:draw, status: 'group_formation') }

    it_behaves_like 'draw intent report'
  end

  def create_student_data(draw:, intents: %w(on_campus))
    students = intents.map do |intent|
      s = create(:student_in_draw, draw: draw)
      s.draw_membership.update!(intent: intent)
      s
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
      student.email, student.student_id, student.last_name, student.first_name,
      student.intent
    ].join(',')
  end
end
