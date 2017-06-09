# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building deletion' do
  before { log_in FactoryGirl.create(:admin) }
  let(:building) { FactoryGirl.create(:building) }

  it 'succeeds' do
    msg = "Building #{building.name} deleted."
    visit building_path(building)
    click_on 'Delete'
    expect(page).to have_content(msg)
  end
end
