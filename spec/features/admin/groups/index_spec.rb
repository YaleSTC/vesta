# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group index' do
  before { log_in create(:user, role: 'superuser') }
  it 'succeeds' do
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Groups'
    expect(page).to have_content('Groups - Back to Vesta')
  end
end
