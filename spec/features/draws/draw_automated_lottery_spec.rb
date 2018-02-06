# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw automatic lottery assignment' do
  let(:clip) { create(:locked_clip) }
  let(:draw) { clip.draw }
  let(:group) { create(:locked_group, :defined_by_draw, draw: draw) }

  it 'can be performed by admins' do
    draw.lottery!
    log_in FactoryGirl.create(:admin)
    visit draw_path(draw)
    click_on 'Automatically assign lottery numbers'
    expect(page).to have_css('.flash-success', text: /selection started/)
  end
end
