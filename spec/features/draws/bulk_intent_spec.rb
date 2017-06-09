# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bulk intent assignment' do
  let(:draw) { FactoryGirl.create(:draw_with_members, status: 'pre_lottery') }

  before do
    log_in FactoryGirl.create(:admin)
    FactoryGirl.create(:student, intent: 'undeclared', draw_id: draw.id)
  end

  it 'can be performed' do
    message = 'All undeclared students set to live on-campus'
    visit draw_path(draw)
    click_on 'Make all students on campus'
    expect(page).to have_css('.flash-success', text: message)
  end
end
