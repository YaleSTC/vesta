# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw activation' do
  let(:draw) do
    create(:draw_with_members, status: 'draft',
                               intent_deadline: Time.zone.tomorrow)
  end

  context 'as admin' do
    before do
      create(:college)
      log_in(create(:admin))
    end

    it 'can be initiated' do
      visit draw_path(draw)
      click_link('Begin intent selection phase')
      expect(page).to have_css('.flash-notice',
                               text: 'Draw successfully initiated.')
    end

    it 'redirects on failure' do
      draw = create(:draw, status: 'draft')
      visit draw_path(draw)
      click_link('Begin intent selection phase')
      expect(page).to have_css('.flash-error')
    end
  end

  context 'as student' do
    before { log_in(create(:student)) }

    it 'cannot see the start button' do
      visit draw_path(draw)
      expect(page).not_to have_link('Begin intent selection phase')
    end
  end
end
