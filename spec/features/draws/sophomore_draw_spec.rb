# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sophomore draws', type: :feature do
  let(:draw) { create(:draw_with_members, status: 'draft') }

  before { log_in(create(:admin)) }

  context 'with undeclared students' do
    before do
      draw.draw_memberships.map { |dm| dm.update!(intent: 'undeclared') }
    end

    it 'can have set all students to on campus' do
      visit draw_path(draw)
      click_link 'Manage intents'
      click_link 'Make all undeclared students on campus'
      expect(page).to have_css('.flash-success', text: /set.+on\-campus/)
    end
  end

  context 'with all intents set' do
    before do
      draw.draw_memberships.map { |dm| dm.update!(intent: 'on_campus') }
    end

    it 'can lock intent' do
      visit draw_path(draw)
      click_link 'Manage intents'
      click_button 'Lock Intents'
      expect(page).to have_css('.flash-notice', text: /updated/)
    end
  end

  context 'with intent locked' do
    before { draw.update!(intent_locked: true) }

    it 'goes straight to group formation' do
      visit draw_path(draw)
      click_link 'Begin group formation phase'
      expect(page).to have_css('.flash-notice', text: /successfully initiated/)
    end
  end
end
