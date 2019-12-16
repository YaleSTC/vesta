# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building show' do
  let(:building_name) { 'Test Building' }

  before do
    log_in create(:user, role: 'superuser')
    create(:building, full_name: building_name)
    visit admin_buildings_path
  end

  it 'succeeds' do
    click_on building_name
    expect(page).to have_content("Show #{building_name}")
  end
end
