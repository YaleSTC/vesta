# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User deletion' do
  before { log_in create(:admin, role: 'admin') }
  let!(:user) { create(:user) }

  it 'succeeds' do
    msg = "User #{user.full_name} deleted."
    navigate_to_view
    within("tr#user-#{user.id}") { click_on 'Remove' }
    expect(page).to have_content(msg)
  end

  def navigate_to_view
    visit root_path
    click_on 'Users'
  end
end
