# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    clip = create(:clip)
    visit admin_clips_path
    destroy_clip(clip.id)
    expect(page).to have_content('Clip was successfully destroyed.')
  end
end

def destroy_clip(clip_id)
  within("tr[data-url='#{admin_clip_path(clip_id)}']") do
    click_on 'Destroy'
  end
end
