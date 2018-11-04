# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite deletion' do
  before { log_in create(:admin) }
  let!(:building) { create(:building) }
  let!(:suite) { create(:suite, building: building) }

  it 'succeeds' do
    msg = "Suite #{suite.number} deleted."
    visit_suite_path(suite)
    click_on 'Delete'
    expect(page).to have_content(msg)
  end

  def visit_suite_path(suite)
    visit building_path(building)
    click_on suite.number.to_s
  end
end
