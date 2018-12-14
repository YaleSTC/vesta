# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College archive' do
  before do
    log_in create(:user, role: 'superuser')
    create(:draw_with_members)
    create(:drawless_group)
  end

  it 'succeeds' do
    visit root_path
    click_on 'Settings'
    click_on 'Archive all data in this college'
    expect(page).to have_css('.flash-success',
                             text: /Past housing data archived/)
  end
end
