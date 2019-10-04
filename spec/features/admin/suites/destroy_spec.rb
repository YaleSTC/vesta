# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    suite = create(:suite)
    visit admin_suites_path
    destroy_suite(suite.id)
    expect(page).to have_content('Suite was successfully destroyed.')
  end

  def destroy_suite(suite_id)
    within("tr[data-url='#{admin_suite_path(suite_id)}']") do
      click_on 'Destroy'
    end
  end
end
