# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building deletion' do
  before { log_in create(:admin) }
  let!(:building) { create(:building) }

  it 'succeeds' do
    msg = "Building #{building.name} deleted."
    navigate_to_view
    find("a[href='#{building_path(building.id)}']").click # Delete
    expect(page).to have_content(msg)
  end

  def navigate_to_view
    visit root_path
    click_on 'Inventory'
    first("a[href='#{building_path(building.id)}']").click
  end
end
