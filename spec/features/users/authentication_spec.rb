# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Authentication' do
  it 'enforces log in to access the app' do
    visit new_draw_path
    expect(page).to have_content('sign in')
  end
  it 'allows users to log in' do
    user = create(:user)
    log_in user
    expect(page).to have_content('Vesta')
  end

  context 'when role set to graduated' do
    let(:student) { create(:student_in_draw, role: 'graduated') }

    it 'does not authorize user' do
      log_in student
      expect(page).to have_content('Your account has been marked as inactive')
    end
  end
end
