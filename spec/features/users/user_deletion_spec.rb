# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User deletion' do
  before { log_in FactoryGirl.create(:admin) }
  let!(:user) { FactoryGirl.create(:user) }

  it 'succeeds' do
    msg = "User #{user.full_name} deleted."
    visit users_path
    within("tr#user-#{user.id}") { click_on 'Remove' }
    expect(page).to have_content(msg)
  end
end
