# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw update' do
  before do
    log_in create(:user, role: 'superuser')
    draw = create(:draw)
    visit admin_draws_path
    click_on_draw_edit(draw.id)
  end

  it 'succeeds' do
    fill_in 'Name', with: 'Test'
    click_on 'Save'
    expect(page).to have_content('Draw was successfully updated.')
  end

  def click_on_draw_edit(draw_id)
    find("a[href='#{edit_admin_draw_path(draw_id)}']").click
  end
end
