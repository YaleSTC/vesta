# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip Deletion' do
  before { log_in FactoryGirl.create(:admin) }
  let(:clip) { FactoryGirl.create(:clip) }

  it 'succeeds' do
    visit clip_path(clip)
    click_on 'Delete'
    expect(page).to have_css('.flash-notice', text: /#{clip.name} deleted./)
  end
end
