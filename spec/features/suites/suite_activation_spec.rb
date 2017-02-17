# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Suite activation' do
  let(:suite) { FactoryGirl.create(:suite, active: false) }
  before { log_in FactoryGirl.create(:admin) }

  it 'can be performed' do
    visit suite_path(suite)
    click_on 'Activate'
    expect(page).to \
      have_css('.flash-success', text: 'Suite successfully activated')
  end
end
