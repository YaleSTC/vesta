# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Nav bar' do
  context 'for non-college host' do
    # change the way the testing suite is configured
    # to allow browsing to the non-college host
    before { Apartment::Tenant.switch!('public') }

    it 'does not render a login link' do
      visit colleges_url(host: env('APPLICATION_HOST'))

      expect(page).not_to have_link('Login')
    end
  end
end
