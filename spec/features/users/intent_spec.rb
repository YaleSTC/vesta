# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Housing Intent' do
  it 'can be indicated' do
    student = FactoryGirl.create(:student)
    log_in student
    declare_off_campus student
    expect(page).to have_css('.user-intent', text: 'off_campus')
  end

  def declare_off_campus(student)
    visit "users/#{student.id}/intent"
    select('off_campus', from: 'user_intent')
    click_on 'Submit Intent'
  end
end
