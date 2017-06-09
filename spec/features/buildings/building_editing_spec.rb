# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building editing' do
  before { log_in FactoryGirl.create(:admin) }
  let(:building) { FactoryGirl.create(:building) }

  it 'succeeds' do
    new_name = 'TD'
    visit edit_building_path(building)
    update_building_name(new_name)
    expect(page).to have_css('.building-name', text: new_name)
  end

  it 'redirects to /edit on failure' do
    visit edit_building_path(building)
    update_building_name('')
    expect(page).to have_content("can't be blank")
  end

  def update_building_name(new_name)
    fill_in 'building_name', with: new_name
    click_on 'Save'
  end
end
