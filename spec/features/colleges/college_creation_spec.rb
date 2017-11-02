# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College creation' do
  before { log_in FactoryGirl.create(:user, role: 'superuser') }
  it 'succeeds' do
    visit root_path
    click_on 'New College'
    submit_college_info(FactoryGirl.attributes_for(:college,
                                                   subdomain: 'newcollege'))
    expect(page).to have_css('.flash-success', text: /College.+created/)
  end

  def submit_college_info(attrs)
    attrs.each { |k, v| fill_in "college_#{k}", with: v }
    click_on 'Create'
  end
end
