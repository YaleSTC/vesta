# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite CSV Import' do
  context 'admin' do
    before { log_in create(:admin) }
    it 'succeeds' do # rubocop:disable RSpec/ExampleLength
      building = create(:building)
      visit building_path(building)
      attach_file('suite_import_form[file]',
                  Rails.root.join('spec', 'fixtures', 'suite_upload.csv'))
      click_on 'Import'
      expect(building.suites.count).to eq(3)
    end
    it 'has a link to template' do
      building = create(:building)
      visit building_path(building)
      click_on 'Download template'
      expect(page).to have_content('Number,Common,Single')
    end
  end

  context 'student' do
    before { log_in create(:student_in_draw) }
    it 'does not show suite_import_form' do
      building = create(:building)
      visit building_path(building)
      expect(page).not_to have_content('Import')
    end
  end
end
