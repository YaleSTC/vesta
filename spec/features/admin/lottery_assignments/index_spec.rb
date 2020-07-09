# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Lottery Assignments index' do
  before { log_in create(:user, role: 'superuser') }
  it 'succeeds' do
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Lottery Assignments'
    expect(page).to have_content('Lottery Assignments')
  end
end
