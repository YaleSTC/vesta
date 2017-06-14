# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite deletion' do
  before { log_in FactoryGirl.create(:admin) }
  let(:suite) { FactoryGirl.create(:suite) }

  it 'succeeds' do
    msg = "Suite #{suite.number} deleted."
    visit suite_path(suite)
    click_on 'Delete'
    expect(page).to have_content(msg)
  end
end
