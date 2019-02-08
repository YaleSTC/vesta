# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bulk intent assignment' do
  let(:draw) { create(:draw_with_members, status: 'group_formation') }

  before do
    log_in create(:admin)
    create(:student_in_draw, intent: 'undeclared', draw: draw)
  end

  it 'can be performed' do
    message = 'All undeclared students set to live on-campus'
    visit draw_path(draw)
    click_on 'Make all students on campus'
    expect(page).to have_css('.flash-success', text: message)
  end

  it 'redirects to the intent report' do
    visit draw_path(draw)
    click_on 'Make all students on campus'
    expect(page).to have_css('h1', text: /Intent Report/)
  end
end
