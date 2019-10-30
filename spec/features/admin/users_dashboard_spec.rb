# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Users Scoped to College' do
  let!(:other_college) { create(:college) }
  let!(:other_student) { create(:user, college: other_college) }

  before { log_in create(:user, role: 'superuser') }
  it 'succeeds' do
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Users'
    expect(page).not_to have_content(other_student.full_name)
  end
end
