# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Drawless Group Archiving' do
  before { log_in create(:admin) }

  it 'succeeds' do
    create(:drawless_group)
    navigate_to_view
    click_on 'Archive all special groups'
    expect(page).to have_css('.flash-success',
                             text: /All active special groups archived./)
  end

  def navigate_to_view
    visit root_path
    click_on 'All Special Groups'
  end
end
