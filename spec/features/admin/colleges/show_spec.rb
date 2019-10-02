# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College show' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_colleges_path
  end

  it 'succeeds' do
    college = create(:college)
    visit current_path
    click_on college.name
    expect(page).to have_content("Show #{college.name}")
  end
end
