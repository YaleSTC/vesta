# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite editing' do
  before { log_in create(:admin) }
  let(:building) { create(:building) }
  let(:suite) { create(:suite, building: building) }

  it 'succeeds' do
    new_number = 'F32'
    visit_edit_suite_path(suite)
    update_suite_number(new_number)
    expect(page).to have_css('.suite-number', text: new_number)
  end

  it 'redirects to /edit on failure' do
    visit_edit_suite_path(suite)
    update_suite_number('')
    expect(page).to have_content('Edit Suite')
  end

  def update_suite_number(new_number)
    fill_in 'suite_number', with: new_number
    click_on 'Save'
  end

  def visit_edit_suite_path(suite)
    visit building_path(building)
    click_on suite.number.to_s
    find("a[href='#{edit_suite_path(suite.id)}']").click
  end
end
