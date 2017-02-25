# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Suite CSV Import' do
  before { log_in FactoryGirl.create(:admin) }
  it 'succeeds' do # rubocop:disable RSpec/ExampleLength
    building = FactoryGirl.create(:building)
    visit building_path(building)
    attach_file('suite_import_form[file]',
                "#{Rails.root}/spec/fixtures/suite_upload.csv")
    click_on 'Import'
    expect(building.suites.count).to eq(2)
  end
end
