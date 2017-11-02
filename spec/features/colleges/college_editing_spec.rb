# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College editing' do
  before { log_in FactoryGirl.create(:admin) }
  let(:college) { FactoryGirl.create(:college) }

  it 'succeeds' do
    new_name = 'TD'
    visit edit_college_path(college)
    update_college_name(new_name)
    expect(page).to have_css('.college-name', text: new_name)
  end

  it 'redirects to /edit on failure' do
    visit edit_college_path(college)
    update_college_name('')
    expect(page).to have_content(/Edit.+Settings/)
  end

  def update_college_name(new_name)
    fill_in 'college_name', with: new_name
    click_on 'Save'
  end
end
