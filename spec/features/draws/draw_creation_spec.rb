# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw Creation' do
  before { log_in FactoryGirl.create(:admin) }
  it 'succeeds' do
    name = 'Sophomore Draw'
    create_draw(name: name)
    expect(page).to have_css('.draw-name', text: name)
  end
  it 'redirects to /new on failure' do
    visit 'draws/new'
    click_on 'Create'
    expect(page).to have_content('New Draw')
  end

  def create_draw(name:)
    visit 'draws/new'
    fill_in 'draw_name', with: name
    click_on 'Create'
  end
end
