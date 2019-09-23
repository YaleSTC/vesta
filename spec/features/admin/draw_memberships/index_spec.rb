# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'DrawMembership index' do
  before { log_in create(:user, role: 'superuser') }
  it 'succeeds' do
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Draw Memberships'
    expect(page).to have_content('Draw Memberships - Back to Vesta')
  end
end
