# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building Creation' do
  before { log_in create(:admin) }
  it 'succeeds' do
    full_name = 'Silliman'
    navigate_to_view
    fill_in 'Full name', with: full_name
    click_on 'Create'
    expect(page).to have_content(full_name)
  end
  it 'redirects to /new on failure' do
    visit 'buildings/new'
    click_on 'Create'
    expect(page).to have_content('errors')
  end

  it 'succeeds with an abbreviation' do
    full_name = 'Silliman'
    abbreviation = 'SI'
    navigate_to_view
    create_building_with_abbreviation(full_name, abbreviation)
    expect(page).to have_content(full_name)
  end

  def navigate_to_view
    visit root_path
    click_on 'Inventory'
    click_on 'Add new building'
  end

  def create_building_with_abbreviation(full_name, abbreviation)
    fill_in 'Full name', with: full_name
    fill_in 'Abbreviation', with: abbreviation
    click_on 'Create'
  end
end
