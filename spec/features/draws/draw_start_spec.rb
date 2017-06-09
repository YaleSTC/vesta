# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw activation' do
  let(:draw) { FactoryGirl.create(:draw_with_members, status: 'draft') }

  context 'as admin' do
    before do
      FactoryGirl.create(:college)
      log_in(FactoryGirl.create(:admin))
    end

    it 'can be initiated' do
      visit draw_path(draw)
      click_link('Begin draw process')
      expect(page).to have_css('.flash-notice',
                               text: 'Draw successfully initiated.')
    end

    it 'redirects on failure' do
      draw = FactoryGirl.create(:draw, status: 'draft')
      visit draw_path(draw)
      click_link('Begin draw process')
      expect(page).to have_css('.flash-error')
    end
  end

  context 'as student' do
    before { log_in(FactoryGirl.create(:student)) }

    it 'cannot see the start button' do
      visit draw_path(draw)
      expect(page).not_to have_link('Begin draw process')
    end
  end
end
