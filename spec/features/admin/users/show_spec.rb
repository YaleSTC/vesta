# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User show' do
  let(:first_name) { 'First' }
  let(:last_name) { 'Last' }

  before do
    log_in create(:user, role: 'superuser')
    create(:user, first_name: first_name)
    visit admin_users_path
  end

  it 'succeeds' do
    click_on first_name
    expect(page).to have_content("Show #{first_name}")
  end
end
