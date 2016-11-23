# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw editing' do
  before { log_in FactoryGirl.create(:admin) }
  let(:draw) { FactoryGirl.create(:draw) }

  it 'succeeds' do
    new_name = 'Froco Draw'
    visit edit_draw_path(draw)
    update_draw_name(new_name)
    expect(page).to have_css('.draw-name', text: new_name)
  end

  it 'redirects to /edit on failure' do
    visit edit_draw_path(draw)
    update_draw_name('')
    expect(page).to have_content('Edit Draw')
  end

  def update_draw_name(new_name)
    fill_in 'draw_name', with: new_name
    click_on 'Save'
  end
end
