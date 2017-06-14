# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite editing' do
  before { log_in FactoryGirl.create(:admin) }
  let(:suite) { FactoryGirl.create(:suite) }

  it 'succeeds' do
    new_number = 'F32'
    visit edit_suite_path(suite)
    update_suite_number(new_number)
    expect(page).to have_css('.suite-number', text: new_number)
  end

  it 'redirects to /edit on failure' do
    visit edit_suite_path(suite)
    update_suite_number('')
    expect(page).to have_content('Edit Suite')
  end

  def update_suite_number(new_number)
    fill_in 'suite_number', with: new_number
    click_on 'Save'
  end
end
