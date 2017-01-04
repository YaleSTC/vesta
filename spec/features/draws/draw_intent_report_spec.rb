# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw intent report' do
  let(:draw) { FactoryGirl.create(:draw) }

  context 'as an admin' do
    before { log_in(FactoryGirl.create(:admin)) }

    it 'is accessible' do
      visit draw_path(draw)
      click_link('View intent report')

      expect(page).to have_css('.report-title',
                               text: "#{draw.name} Intent Report")
    end

    it 'displays tables with the appropriate users', :js do
      intent_users = create_intent_users(draw)

      visit draw_intent_report_path(draw)
      save_and_open_page

      # expect(page_has_correct_intent_report(page, intent_users))
      intent_users.each do |status, student|
        expect(page).to have_css("#student-#{student.id} .student-first", text: student.name)
        expect(page).to have_css("#student-#{student.id} .student-last", text: student.last_name)
        expect(page).to have_css("#student-#{student.id} .student-intent", text: intent)
      end
    end

    def create_intent_users(draw)
      User.intents.keys.map do |intent|
        [intent, FactoryGirl.create(:user, draw: draw, intent: intent)]
      end.to_h
    end

    def page_has_correct_intent_report(page, intent_users)
      intent_users.all? do |status, user|
        page.has_css?("tr\#student-#{user.id} .student-first", text: user.name) &&
            page.has_css?("tr\#student-#{user.id} .student-last", text: user.last_name) &&
            page.has_css?("tr\#student-#{user.id} .student-intent", text: status)
      end
    end
  end

  context 'as a student' do
    before { log_in(FactoryGirl.create(:student)) }

    it 'does not have a link on the status page' do
      visit draw_path(draw)

      expect(page).not_to have_link('View intent report',
                                    href: draw_intent_report_path(draw))
    end
  end
end
