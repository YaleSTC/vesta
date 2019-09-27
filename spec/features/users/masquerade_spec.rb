# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Masquerading' do
  let(:user) { create(:student) }
  let(:second_user) { create(:student) }

  before { log_in create(:admin) }

  it 'allows admin to masquerade as student' do
    masquerade!
    expect(page).not_to have_content('Setup')
  end

  it 'shows admin is masquerading' do
    masquerade!
    expect(page).to have_content('Stop Masquerading')
  end

  it 'shows a flash' do
    masquerade!
    expect(page).to have_content("Masquerading as #{user.full_name}")
  end

  it 'allows admin to end masquerade' do
    masquerade!
    click_on 'Stop Masquerading'
    expect(page).to have_content('Setup')
  end

  it 'sends flash upon stop' do
    masquerade!
    click_on 'Stop Masquerading'
    expect(page).to have_content('Stopped masquerading')
  end

  it 'safely ends masquerade session upon log out' do
    masquerade!
    click_on 'Log Out'
    log_in second_user
    expect(page).not_to have_content('Stop Masquerading')
  end

  def masquerade!
    visit user_path(user)
    click_on 'Masquerade'
  end
end
