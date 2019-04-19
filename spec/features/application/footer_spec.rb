# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Footer' do
  it 'has a link to About Us page' do
    visit root_path
    click_on 'About Us'
    expect(page).to have_content('Named after the Roman goddess')
  end

  context 'for non-college host' do
    before { Apartment::Tenant.switch!('public') }

    it 'has a link to About Us page' do
      visit root_path
      click_on 'About Us'
      expect(page).to have_content('Named after the Roman goddess')
    end
  end
end
