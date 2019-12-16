# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building create' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_buildings_path
  end

  it 'succeeds' do
    click_on 'New building'
    fill_in 'Full name', with: 'Test'
    click_on 'Create'
    expect(page).to have_content('Building was successfully created.')
  end
end
