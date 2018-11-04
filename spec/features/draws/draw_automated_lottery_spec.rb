# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw automatic lottery assignment' do
  let!(:draw) { create(:draw) }
  let(:clip) { create(:locked_clip, draw: draw) }

  context 'navigating' do
    before { create(:locked_group, :defined_by_draw, draw: draw) }
    it 'navigates to view from dashboard' do
      log_in create(:admin)
      first(:link, draw.name).click
      proceed_to_lottery
      expect(page).to have_content('Automatically assign lottery numbers')
    end
  end

  it 'can be performed by admins' do
    draw.lottery!
    log_in create(:admin)
    visit draw_path(draw)
    click_on 'Automatically assign lottery numbers'
    expect(page).to have_css('.flash-success', text: /selection started/)
  end

  def proceed_to_lottery
    click_on 'Proceed to lottery'
    click_on 'Proceed to lottery'
  end
end
