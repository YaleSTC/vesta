# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building Creation' do
  before { log_in create(:admin) }
  it 'succeeds' do
    name = 'Silliman'
    navigate_to_view
    fill_in 'building_name', with: name
    click_on 'Create'
    expect(page).to have_content(name)
  end
  it 'redirects to /new on failure' do
    visit 'buildings/new'
    click_on 'Create'
    expect(page).to have_content('errors')
  end

  def navigate_to_view
    visit root_path
    click_on 'Inventory'
    click_on 'Add new building'
  end
end
