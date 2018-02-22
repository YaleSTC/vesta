# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Terms of service' do
  context 'as a student' do
    let(:user) { create(:user, tos_accepted: nil) }

    it 'the form can be accepted' do
      log_in user
      click_on 'Accept Terms of Service'
      expect(page).to have_css('.flash-success', text: /Welcome to Vesta/)
    end
    it 'pages redirect to the tos if it is not accepted' do
      log_in user
      visit user_path(user)
      expect(page).to have_content('Terms of Service')
    end
    it 'will not redirect if the terms of service is accepted' do
      user.update!(tos_accepted: Time.current)
      log_in user
      visit user_path(user)
      msg = 'You must accept the Terms of Service to proceed.'
      expect(page).not_to have_content(msg)
    end
  end
  context 'as an admin' do
    let(:user) { create(:admin) }

    it 'the acceptance link does not appear' do
      log_in user
      visit terms_of_service_path
      expect(page).not_to have_link('Accept Terms of Service')
    end
  end
end
