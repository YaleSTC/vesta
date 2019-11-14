# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    user = create(:user)
    visit admin_users_path
    destroy_user(user.id)
    expect(page).to have_content('User was successfully destroyed.')
  end

  def destroy_user(user_id)
    within("tr[data-url='#{admin_user_path(user_id)}']") do
      click_on 'Destroy'
    end
  end
end
