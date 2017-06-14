# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite splitting' do
  let(:suite) { FactoryGirl.create(:suite_with_rooms, rooms_count: 2) }

  before { log_in FactoryGirl.create(:admin) }

  it 'can be performed' do
    initiate_suite_split
    fill_in_split_info(%w(new_suite_1 new_suite_2))
    expect(page).to have_css('.flash-success', text: 'Suite successfully split')
  end

  def initiate_suite_split
    visit suite_path(suite)
    click_on 'Split suite'
  end

  def fill_in_split_info(suite_names)
    suite.rooms.each_with_index do |room, index|
      fill_in "suite_split_form_room_#{room.id}_suite", with: suite_names[index]
    end
    click_on 'Split suite'
  end
end
