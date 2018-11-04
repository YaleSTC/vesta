# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite CSV Import' do
  let!(:building) { create(:building) }

  context 'navigating' do
    it 'navigates to view from dashboard' do
      log_in create(:admin)
      visit root_path
      click_on 'Inventory'
      first("a[href='#{building_path(building.id)}']").click
      expect(page).to have_content('Upload a CSV')
    end
  end

  context 'admin' do
    before { log_in create(:admin) }
    it 'succeeds' do
      visit building_path(building)
      attach_file('suite_import_form[file]',
                  Rails.root.join('spec', 'fixtures', 'suite_upload.csv'))
      click_on 'Import'
      expect(building.suites.count).to eq(3)
    end
    it 'flashes error if no csv file is uploaded' do
      visit building_path(building)
      click_on 'Import'
      expect(page).to have_content('No file uploaded')
    end
    it 'has a link to template' do
      visit building_path(building)
      click_on 'Download template'
      expect(page).to have_content('Number,Common,Single')
    end
  end

  context 'student' do
    before { log_in create(:student_in_draw) }
    it 'does not show suite_import_form' do
      visit building_path(building)
      expect(page).not_to have_content('Import')
    end
  end
end
