# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'User Editing' do
  let(:user) { FactoryGirl.create(:student) }
  before { log_in FactoryGirl.create(:admin) }
  it 'can update role' do
    visit edit_user_path(user)
    select('rep', from: 'user_role')
    click_on 'Save'
    expect(page).to have_css('.user-role', text: 'rep')
  end
end
