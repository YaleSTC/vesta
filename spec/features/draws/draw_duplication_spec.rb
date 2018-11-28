# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw Duplication' do
  before { log_in create(:admin) }
  let(:draw) { create(:draw_in_lottery) }

  it 'succeeds' do
    visit draw_path(draw)
    click_on 'Copy draw'
    draw_copy_name = draw.name + '-copy'
    expect(page).to have_content(draw_copy_name)
  end
end
