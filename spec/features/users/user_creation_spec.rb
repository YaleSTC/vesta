# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Users Creatable by Admins' do
  before { log_in FactoryGirl.create(:admin) }
  it 'succeeds' do
    visit new_user_path()
    fill_in 'user_first_name', with: 'Elihu'
    fill_in 'user_last_name', with: 'Yale'
    fill_in 'user_email', with: 'elihu.yale@yale.edu'
    select('off_campus', from: 'user_intent')
    save_and_open_page()
    click_on 'Create'
    user = User.find_by(first_name: 'Elihu')
    print ' trying'
    if user == nil
    	save_and_open_page()
    else
      print 'working work working'
   	end
    expect(page).to have_content('Elihu')
  end
  it 'redirects to /new on failure' do
    visit new_user_path()
    click_on 'Create'
    expect(page).to have_content('errors')
  end
end
