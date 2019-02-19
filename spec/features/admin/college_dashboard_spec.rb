# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College edit' do
  before { log_in create(:user, role: 'superuser') }
  it 'succeeds' do
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Colleges'
    click_on 'Edit'
    find('#college_size_sort').find(:xpath, 'option[2]').select_option
  end
end
