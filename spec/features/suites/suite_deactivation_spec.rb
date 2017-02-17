# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Suite deactivation' do
  let(:suite) { FactoryGirl.create(:suite, active: true) }
  before { log_in FactoryGirl.create(:admin) }

  it 'can be performed' do
    visit suite_path(suite)
    click_on 'Deactivate'
    expect(page).to \
      have_css('.flash-success', text: 'Suite successfully deactivated')
  end
end
