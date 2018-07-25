# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite Creation' do
  before { log_in create(:admin) }
  it 'succeeds' do
    building = create(:building)
    visit new_building_suite_path(building)
    fill_in_suite_info(suite_number: 'L01')
    click_on 'Create'
    expect(page).to have_content('L01')
  end
  it 'redirects to /new on failure' do
    visit new_building_suite_path(create(:building))
    click_on 'Create'
    expect(page).to have_content('errors')
  end

  def fill_in_suite_info(**attrs)
    attrs.each { |a, v| fill_in a.to_s, with: v }
  end
end
