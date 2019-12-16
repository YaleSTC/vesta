# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building update' do
  before do
    log_in create(:user, role: 'superuser')
    building = create(:building)
    visit admin_buildings_path
    click_on_building_edit(building.id)
  end

  it 'succeeds' do
    fill_in 'Full name', with: 'Test'
    click_on 'Save'
    expect(page).to have_content('Building was successfully updated.')
  end

  def click_on_building_edit(building_id)
    find("a[href='#{edit_admin_building_path(building_id)}']").click
  end
end
