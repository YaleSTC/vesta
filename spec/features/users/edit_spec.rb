# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User Editing' do
  let(:user) { FactoryGirl.create(:student) }

  before { log_in FactoryGirl.create(:admin) }
  it 'can update role' do
    visit_edit_form(user)
    select('rep', from: 'user_role')
    click_on 'Save'
    expect(page).to have_css('.user-role', text: 'Rep')
  end
  it 'can update first name' do
    visit_edit_form(user)
    fill_in 'First name', with: 'Captain'
    click_on 'Save'
    expect(page).to have_css('.user-name', text: /Captain/)
  end
  it 'can update email' do
    visit_edit_form(user)
    fill_in 'Email', with: 'foo@foo.com'
    click_on 'Save'
    expect(page).to have_css('.user-email', text: 'foo@foo.com')
  end

  def visit_edit_form(user)
    visit user_path(user)
    click_on 'Edit'
  end
end
