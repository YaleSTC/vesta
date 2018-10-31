# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw suite size restricting' do
  before { log_in create(:admin) }
  let(:draw) do
    create(:draw, status: 'group_formation').tap do |d|
      d.suites << Array.new(3) do |i|
        create(:suite_with_rooms, rooms_count: i + 1)
      end
      d.restricted_sizes << 1
    end
  end

  it 'succeeds' do
    visit edit_draw_path(draw)
    check('Doubles')
    uncheck('Singles')
    click_on 'Save'
    expect(draw.reload.restricted_sizes).to eq([2])
  end

  describe 'restrict all sizes' do
    it 'can can be done from the draw page' do
      visit draw_path(draw)
      click_on 'Restrict all sizes'
      expect(page).to have_css('.flash-notice', text: "#{draw.name} updated")
    end

    it 'works' do
      visit draw_path(draw)
      click_on 'Restrict all sizes'
      expect(draw.reload.restricted_sizes).to eq(draw.suite_sizes)
    end
  end
end
