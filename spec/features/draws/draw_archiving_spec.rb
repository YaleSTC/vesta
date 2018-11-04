# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw archiving' do
  before { log_in create(:admin) }
  let!(:draw) { create(:draw_with_members) }

  it 'succeeds' do
    navigate_to_view
    click_on 'Archive draw'
    expect(page).to have_css('.flash-success', text: /Draw archived/)
  end

  def navigate_to_view
    visit root_path
    first(:link, draw.name).click
  end
end
