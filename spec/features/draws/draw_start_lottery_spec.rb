# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw start lottery' do
  let(:draw) { FactoryGirl.create(:draw_with_members, status: 'pre_lottery') }
  before do
    log_in FactoryGirl.create(:admin)
    FactoryGirl.create(:locked_group, leader: draw.students.first)
  end

  it 'can be done' do
    visit draw_path(draw)
    click_on 'Proceed to Lottery'
    click_on 'Proceed to Lottery'
    expect(page).to have_css('.flash-success',
                             text: 'You can now assign lottery numbers')
  end
end
