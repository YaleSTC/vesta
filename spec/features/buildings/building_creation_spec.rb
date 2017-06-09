# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building Creation' do
  before { log_in FactoryGirl.create(:admin) }
  it 'succeeds' do
    visit 'buildings/new'
    name = 'Silliman'
    fill_in 'building_name', with: name
    click_on 'Create'
    expect(page).to have_content(name)
  end
  it 'redirects to /new on failure' do
    visit 'buildings/new'
    click_on 'Create'
    expect(page).to have_content('errors')
  end
end
