# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room deletion' do
  before { log_in create(:admin) }
  let!(:building) { create(:building) }
  let!(:suite) { create(:suite, building: building) }
  let!(:room) { create(:room, suite: suite) }

  it 'succeeds' do
    msg = "Room #{room.number} deleted."
    navigate_to_view
    click_on 'Delete'
    expect(page).to have_content(msg)
  end

  # rubocop:disable Metrics/AbcSize
  def navigate_to_view
    click_on 'Inventory'
    first("a[href='#{building_path(building.id)}']").click
    first("a[href='#{suite_path(suite.id)}']").click
    first("a[href='#{room_path(room.id)}']").click
  end
  # rubocop:enable Metrics/AbcSize
end
