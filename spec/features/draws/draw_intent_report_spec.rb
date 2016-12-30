# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw intent report' do
  let(:draw) { FactoryGirl.create(:draw) }

  context 'as an admin' do
    before { log_in(FactoryGirl.create(:admin)) }

    it 'displays tables with the appropriate users' do
      intent_users = create_intent_users(draw)

      visit intent_report_draw_path(draw)

      expect(page_has_correct_intent_report(page, intent_users))
    end

    def create_intent_users(draw)
      User.intents.keys.map do |intent|
        [intent, FactoryGirl.create(:user, draw: draw, intent: intent)]
      end.to_h
    end

    def page_has_correct_intent_report(page, intent_users)
      intent_users.all? do |status, user|
        # TODO: figure out if we want to just have one sortable table
        within(:css, ".#{status}-table") do
          page.has_css?('.student-name', text: user.name)
          # somehow chekc that it also includes the dropdown form to change
          # intent
        end
      end
    end
  end
end
