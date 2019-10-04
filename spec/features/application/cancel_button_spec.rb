# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Cancel Button' do
  before { log_in create(:admin) }
  let(:draw) { create(:draw) }
  let(:user) { create(:student) }

  it 'redirects to referrer param if exists' do
    visit users_path
    visit edit_user_path(user.id) + "?referrer=%2Fdraws%2F#{draw.id}"
    click_on 'Cancel'
    expect(page).to have_current_path("/draws/#{draw.id}")
  end

  describe 'redirects to refering page if exists', js: true do
    xit 'from user index returns back to index' do
      visit users_path
      click_on 'Edit'
      click_on 'Cancel'
      expect(page).to have_current_path(users_path)
    end

    xit 'from user view returns back to view' do
      visit user_path(user)
      click_on 'Edit'
      click_on 'Cancel'
      expect(page).to have_current_path(user_path(user))
    end
  end
end
