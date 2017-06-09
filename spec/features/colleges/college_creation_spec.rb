# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Building Creation' do
  before { log_in FactoryGirl.create(:admin) }
  it 'succeeds' do
    visit new_college_path
    submit_college_info(FactoryGirl.attributes_for(:college))
    expect(page).to have_css('.flash-success', text: /College.+created/)
  end

  def submit_college_info(attrs)
    attrs.each { |k, v| fill_in "college_#{k}", with: v }
    click_on 'Create'
  end
end
