# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite unmerging' do
  let(:suite) do
    FactoryGirl.create(:suite_with_rooms)
  end
  let!(:other_suite) do
    FactoryGirl.create(:suite_with_rooms, building: suite.building)
  end

  before { log_in FactoryGirl.create(:admin) }

  it 'can be performed after a merge' do
    visit suite_path(suite)
    perform_merge
    click_on 'Unmerge suite'
    expect(page).to have_content('Suite successfully split')
  end

  def perform_merge
    fill_in 'suite_merger_form_other_suite_number', with: other_suite.number
    click_on 'Merge'
    fill_in 'suite_merger_form_number', with: suite.number
    click_on 'Merge'
  end
end
