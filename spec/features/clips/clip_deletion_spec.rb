# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip Deletion' do
  let!(:draw) { create(:draw, status: 'group_formation') }
  let!(:groups) { create_pair(:group_from_draw, draw: draw) }
  let!(:clip) { create(:clip, draw: draw, groups: groups) }

  before { log_in create(:admin) }

  it 'succeeds' do
    navigate_to_view
    click_on 'Delete'
    expect(page).to have_css('.flash-notice', text: /#{clip.name} deleted./)
  end

  def navigate_to_view
    first(:link, draw.name).click
    first("a[href='#{clip_path(clip.id)}']").click
  end
end
