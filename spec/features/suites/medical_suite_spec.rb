# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Medical suites' do
  let(:suite) { FactoryGirl.create(:suite) }

  before { log_in FactoryGirl.create(:admin) }

  it 'can be toggled from the edit form' do
    visit edit_suite_path(suite)
    check 'Medical suite'
    click_on 'Save'
    expect(page).to have_css('.suite-medical', text: 'Medical suite')
  end

  it 'can be done from the suite page' do
    visit suite_path(suite)
    click_on 'Make medical suite'
    expect(page).to have_css('.suite-medical', text: 'Medical suite')
  end
end
