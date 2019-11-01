# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip show' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_clips_path
  end

  it 'succeeds' do
    clip = create(:clip)
    visit current_path
    click_on "#{clip.size} groups"
    expect(page).to have_content("Show #{clip.name}")
  end
end
