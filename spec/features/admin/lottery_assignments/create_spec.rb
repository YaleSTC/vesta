# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Lottery Assignment create' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_lottery_assignments_path
  end

  it 'succeeds' do
    draw = create(:draw_in_lottery)
    group = create(:locked_group, :defined_by_draw, draw: draw)
    create_lottery_assignment(draw, group)
    expect(page).to have_content('LotteryAssignment was successfully created.')
  end

  def create_lottery_assignment(draw, group)
    click_on 'New lottery assignment'
    select draw.name, from: 'Draw'
    fill_in 'Number', with: '1'
    select group.name, from: 'groups'
    click_on 'Create'
  end
end
