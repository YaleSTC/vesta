# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite unmerging' do
  let(:numbers) { %w(L01 I33) }
  let(:suite) do
    FactoryGirl.create(:suite).tap do |s|
      rooms = numbers.map { |n| FactoryGirl.create(:room, original_suite: n) }
      s.rooms << rooms.flatten
    end
  end

  before { log_in FactoryGirl.create(:admin) }

  it 'can be performed' do
    visit suite_path(suite)
    click_on 'Unmerge suite'
    expect(page).to have_content('Suite successfully split')
  end
end
