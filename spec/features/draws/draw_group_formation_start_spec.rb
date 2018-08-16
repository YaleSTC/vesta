# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw activation' do
  let(:draw) { create(:draw_with_members, status: 'intent_selection') }

  context 'as admin' do
    before do
      create(:college)
      log_in(create(:admin))
    end

    it 'can be initiated' do
      visit draw_path(draw)
      click_link('Proceed to group formation phase')
      expect(page).to have_css('.flash-notice',
                               text: 'Draw successfully updated.')
    end

    it 'redirects on failure' do
      draw = create(:draw, status: 'intent_selection')
      visit draw_path(draw)
      click_link('Proceed to group formation phase')
      expect(page).to have_css('.flash-error')
    end
  end

  context 'as student' do
    before { log_in(create(:student)) }

    it 'cannot see the start button' do
      visit draw_path(draw)
      expect(page).not_to have_link('Proceed to group formation phase')
    end
  end
end
