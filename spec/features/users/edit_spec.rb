# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'User Editing' do
  let(:user) { FactoryGirl.create(:student, gender: 'non-binary') }
  before { log_in user }
  it 'can update gender' do
    visit edit_user_path(user)
    select('male', from: 'user_gender')
    click_on 'Save'
    expect(page).to have_css('.user-gender', text: 'male')
  end
end
