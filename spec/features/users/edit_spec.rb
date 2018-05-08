# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User Editing' do
  let(:user) { create(:student) }

  before { log_in create(:admin, role: 'superadmin') }
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
  it 'changes tenant when changing college' do
    new_college = create(:college)
    visit_edit_form(user)
    select(new_college.name.to_s, from: 'College')
    click_on 'Save'
    expect(page.current_url).to match(new_college.name.downcase)
  end
  it 'will not let you edit users from other colleges' do
    new_user = create(:user, college_id: create(:college).id)
    expect { visit_edit_form(new_user) }.to \
      raise_error(ActiveRecord::RecordNotFound)
  end

  def visit_edit_form(user)
    visit user_path(user)
    click_on 'Edit'
  end
end
