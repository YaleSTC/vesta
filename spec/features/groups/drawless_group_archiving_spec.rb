# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Drawless Group Archiving' do
  before { log_in create(:admin) }

  it 'succeeds' do
    create(:drawless_group)
    visit groups_path
    click_on 'Archive all special groups'
    expect(page).to have_css('.flash-success',
                             text: /All active special groups archived./)
  end
end
