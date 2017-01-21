# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Users Creatable by Admins' do
  before { log_in FactoryGirl.create(:admin) }
  it 'succeeds' do
    visit new_user_path()
    fill_in 'First name', with: 'Elihu'
    fill_in 'Last name', with: 'Yale'
    fill_in 'Email', with: 'elihu.yale@yale.edu'
    click_on 'Create'
    @user = User.find_by(first_name: 'Elihu')
    if @user == nil
    	save_and_open_page();
   	end
    expect(page).to have_content('Elihu')
  end
  it 'redirects to /new on failure' do
    visit new_user_path()
    click_on 'Create'
    expect(page).to have_content('errors')
  end
end
