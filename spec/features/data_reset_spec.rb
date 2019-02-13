# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Data reset', type: :feature do
  let(:group) { create(:drawless_group) }
  let(:suite) { create(:suite, size: group.size) }

  before do
    group.update!(suite: suite)
    log_in create(:user, role: 'superuser')
    click_link 'Settings'
  end

  it 'shows suites as available' do
    click_link 'Archive all data in this college'
    visit suite_path(suite)
    expect(page).to have_css('li', text: 'Status: Available')
  end

  it 'allows suites to be added to draws' do
    click_link 'Archive all data in this college'
    visit draw_path(create(:draw))
    click_link 'Add or edit suites'
    selector = "input#draw_suites_update_drawless_ids_#{suite.size}_#{suite.id}"
    expect(page).to have_css(selector)
  end
end
