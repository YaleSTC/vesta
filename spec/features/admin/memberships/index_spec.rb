# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Memberships index' do
  before { log_in create(:user, role: 'superuser') }
  it 'succeeds' do
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Memberships'
    expect(page).to have_content('Memberships')
  end
end
