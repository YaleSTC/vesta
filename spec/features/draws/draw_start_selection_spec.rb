# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw start selection' do
  let(:draw) { create(:draw_in_lottery) }

  before do
    create(:college)
    log_in create(:admin)
    draw.groups.each do |g|
      create(:lottery_assignment, groups: [g], draw: draw)
    end
  end

  it 'can be done' do
    navigate_to_view
    click_on 'Start suite selection'
    expect(page).to have_css('.flash-success', text: 'Suite selection started')
  end

  def navigate_to_view
    visit root_path
    first(:link, draw.name).click
  end
end
