# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Nav bar' do
  context 'for non-college host' do
    # change the way the testing suite is configured
    # to allow browsing to the non-college host
    before { Apartment::Tenant.switch!('public') }

    it 'does not render a login link' do
      visit colleges_url(host: env('APPLICATION_HOST'))

      expect(page).not_to have_link('Log In')
    end
  end

  context 'as a student' do
    context 'not part of a draw' do
      it 'does not show My Draw' do
        user = create(:user, role: 'student')
        log_in user
        expect(page).not_to have_link('My Draw', href: '#')
      end
    end
  end

  context 'as a rep' do
    context 'no draws present' do
      it 'does not show draws dropdown' do
        user = create(:user, role: 'rep')
        log_in user
        expect(page).not_to have_link('Draws', href: '#')
      end
    end
  end
end
