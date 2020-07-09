# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip create' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_clips_path
  end

  it 'succeeds' do
    draw = create(:draw)
    group = create(:group_from_draw, draw: draw)
    create_clip(draw, group)
    expect(page).to have_content('Clip was successfully created.')
  end

  def create_clip(draw, group)
    click_on 'New clip'
    select draw.name, from: 'Draw'
    select group.name, from: 'Groups'
    click_on 'Create'
  end
end
