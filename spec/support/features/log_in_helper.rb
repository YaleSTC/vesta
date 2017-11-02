# frozen_string_literal: true

def log_in(user)
  password = user.password || attributes_for(:user)[:password]
  visit '/users/sign_in'
  fill_in 'user_email', with: user.email
  fill_in 'user_password', with: password
  click_on 'Log in'
end
