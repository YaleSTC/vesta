# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    draw = create(:draw)
    visit admin_draws_path
    destroy_draw(draw.id)
    expect(page).to have_content('Draw was successfully destroyed.')
  end

  def destroy_draw(draw_id)
    within("tr[data-url='#{admin_draw_path(draw_id)}']") do
      click_on 'Destroy'
    end
  end
end
