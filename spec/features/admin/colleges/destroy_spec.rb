# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    college = create(:college)
    visit admin_colleges_path
    destroy_college(college.id)
    expect(page).to have_content('College was successfully destroyed.')
  end

  def destroy_college(college_id)
    within("tr[data-url='#{admin_college_path(college_id)}']") do
      click_on 'Destroy'
    end
  end
end
