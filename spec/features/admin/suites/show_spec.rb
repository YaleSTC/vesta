# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite show' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    suite = create(:suite)
    visit admin_suites_path
    click_on suite.number
    expect(page).to have_content("Show Suite #{suite.number}")
  end
end
