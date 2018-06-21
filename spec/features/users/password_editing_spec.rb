# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Password Editing' do
  let!(:student) { create(:student) }

  describe 'account details page' do
    it 'can be accessed by the same user' do
      log_in student
      visit_account
      expect(page).to have_content('Change Password')
    end
  end
  it "admins cannot change other user's passwords" do
    admin = create(:admin)
    log_in admin
    visit user_path(student)
    expect(page).not_to have_content('Change Password')
  end
  describe 'change password page' do
    let(:new_password) { 'passw1rd' }

    before do
      log_in student
      visit edit_password_user_path(student)
    end
    it 'allows users to edit passwords' do
      change_password
      student.reload
      expect(student.valid_password?(new_password)).to eq(true)
    end
    it 'displays message when password successfully changed' do
      change_password
      expect(page).to have_content('Password successfully changed')
    end
    def change_password
      fill_in 'Current Password', with: student.password
      fill_in 'New Password', with: new_password
      fill_in 'New Password Confirmation', with: new_password
      click_on 'Update'
    end
  end

  def visit_account
    visit root_path
    click_on 'My Profile'
  end
end
