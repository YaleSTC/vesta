# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Tag editing' do
  before { log_in FactoryGirl.create(:admin) }
  let(:tag) { FactoryGirl.create(:tag) }

  it 'succeeds' do
    new_name = 'TD'
    visit edit_tag_path(tag)
    update_tag_name(new_name)
    expect(page).to have_css('.tag-name', text: new_name)
  end

  it 'redirects to /edit on failure' do
    visit edit_tag_path(tag)
    update_tag_name('')
    expect(page).to have_content('Edit Tag')
  end

  def update_tag_name(new_name)
    fill_in 'tag_name', with: new_name
    click_on 'Save'
  end
end
