# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Time out' do
  before { log_in create(:user) }
  it 'logs user out if the session extends past 24 hours' do
    Timecop.travel(Time.zone.now + 2.days) do
      # The user will be kicked to the time out page only when they try to do
      # something after the session expires, not as soon as it expires.
      visit root_path
      expect(page).to have_content('Your session expired. Please sign in'\
          ' again to continue.')
    end
  end
end
