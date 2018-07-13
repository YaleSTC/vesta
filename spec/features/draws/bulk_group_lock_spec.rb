# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bulk group locking' do
  let(:draw) { create(:draw_with_groups, status: 'pre_lottery') }
  let(:oversubd) { create(:oversubscribed_draw) }

  before do
    log_in create(:admin)
  end

  it 'can be performed' do
    message = 'All groups have been locked'
    visit draw_path(draw)
    click_on 'Lock all full groups'
    expect(page).to have_css('.flash-success', text: message)
  end

  it 'will fail for oversubscribed draws' do
    message = 'You must handle oversubscription before locking groups'
    visit draw_path(oversubd)
    click_on 'Lock all full groups'
    expect(page).to have_css('.flash-error', text: message)
  end
end
