# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw show' do
  let(:draw_name) { 'Test Draw' }

  before do
    log_in create(:user, role: 'superuser')
    create(:draw, name: draw_name)
    visit admin_draws_path
  end

  it 'succeeds' do
    click_on draw_name
    expect(page).to have_content("Show #{draw_name}")
  end
end
