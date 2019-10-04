# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    building = create(:building)
    visit admin_buildings_path
    destroy_building(building.id)
    expect(page).to have_content('Building was successfully destroyed.')
  end

  def destroy_building(building_id)
    within("tr[data-url='#{admin_building_path(building_id)}']") do
      click_on 'Destroy'
    end
  end
end
