# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clips index' do
  before { log_in create(:user, role: 'superuser') }
  it 'succeeds' do
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Clips'
    expect(page).to have_content('Clips')
  end
end
