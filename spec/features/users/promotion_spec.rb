# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User Promotion' do
  before { log_in FactoryGirl.create(:admin) }
  it 'can be performed' do
    user = FactoryGirl.create(:user)
    visit edit_user_path(user)
    select('rep', from: 'user_role')
    click_on 'Save'
    expect(page).to have_css('.user-role', text: 'Rep')
  end
end
