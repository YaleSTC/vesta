# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw deletion' do
  before { log_in create(:admin) }
  let(:draw) { create(:draw_with_members) }

  it 'succeeds' do
    msg = "Draw #{draw.name} deleted."
    visit draw_path(draw)
    click_on 'Delete draw'
    expect(page).to have_content(msg)
  end
end
